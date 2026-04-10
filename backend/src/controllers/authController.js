const crypto = require('crypto');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const UserAuthProvider = require('../models/UserAuthProvider');
const sendEmail = require('../utils/email');

const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET, { expiresIn: '7d' });
};

// @desc    Register new user
const register = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    const userExists = await User.findOne({ email });
    if (userExists) {
      return res.status(400).json({ success: false, message: 'User already exists' });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const emailVerifyToken = crypto.randomBytes(32).toString('hex');

    const user = await User.create({
      email,
      password: hashedPassword,
      emailVerifyToken
    });

    const verifyUrl = `${process.env.FRONTEND_URL || 'http://localhost:3000'}/verify-email?token=${emailVerifyToken}`;
    
    await sendEmail({
      email: user.email,
      subject: 'Verify your email address',
      message: `You are receiving this email because you (or someone else) have registered an account. \n\nPlease click on the following link, or paste this into your browser to complete the process: \n\n${verifyUrl}`
    });

    res.status(201).json({
      success: true,
      data: {
        id: user._id,
        email: user.email,
        setupCompleted: user.setupCompleted
      },
      message: 'Registration successful. Please check your email to verify your account.'
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Verify Email
const verifyEmail = async (req, res, next) => {
  try {
    const { token } = req.body;

    const user = await User.findOne({ emailVerifyToken: token });

    if (!user) {
      return res.status(400).json({ success: false, message: 'Invalid or expired verification token' });
    }

    user.isEmailVerified = true;
    user.emailVerifyToken = undefined;
    await user.save();

    res.status(200).json({
      success: true,
      message: 'Email verified successfully'
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Login
const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ email });
    if (!user || !user.password) {
      return res.status(401).json({ success: false, message: 'Invalid email or password' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ success: false, message: 'Invalid email or password' });
    }

    if (!user.isEmailVerified) {
      return res.status(401).json({ success: false, message: 'Please verify your email first' });
    }

    res.status(200).json({
      success: true,
      token: generateToken(user._id)
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Generic OAuth login
const socialAuth = async (req, res, next) => {
  try {
    const provider = req.params.provider; // google, facebook, apple
    const { providerId, email, name, avatarUrl } = req.body;

    // Check if this providerId is already linked
    let authProvider = await UserAuthProvider.findOne({ provider, providerId });
    let user;

    if (authProvider) {
      user = await User.findById(authProvider.user);
    } else {
      // Find user by email or create a new one
      user = await User.findOne({ email });

      if (!user) {
        user = await User.create({
          email,
          name, // NOTE: user schema doesn't have name initially in this code? Ah, we can push it, wait, User doesn't have name, avatarUrl is there.
          avatarUrl,
          isEmailVerified: true
        });
      } else {
        if (!user.isEmailVerified) {
          user.isEmailVerified = true;
          await user.save();
        }
      }

      await UserAuthProvider.create({
        user: user._id,
        provider,
        providerId,
        email,
        name,
        avatarUrl
      });
    }

    res.status(200).json({
      success: true,
      token: generateToken(user._id)
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Forgot Password
const forgotPassword = async (req, res, next) => {
  try {
    const { email } = req.body;

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ success: false, message: 'There is no user with that email address' });
    }

    const resetToken = crypto.randomBytes(32).toString('hex');

    user.passwordResetToken = resetToken;
    user.passwordResetExpires = Date.now() + 60 * 60 * 1000;
    await user.save();

    const resetUrl = `${process.env.FRONTEND_URL || 'http://localhost:3000'}/reset-password?token=${resetToken}`;
    
    await sendEmail({
      email: user.email,
      subject: 'Your password reset token (valid for 1 hour)',
      message: `Forgot your password? Submit a POST request with your new password to this endpoint along with the token: \n\n${resetUrl}\n\nIf you didn't forget your password, please ignore this email!`
    });

    res.status(200).json({
      success: true,
      message: 'Password reset token sent to email'
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Reset Password
const resetPassword = async (req, res, next) => {
  try {
    const { token, password } = req.body;

    const user = await User.findOne({
      passwordResetToken: token,
      passwordResetExpires: { $gt: Date.now() }
    });

    if (!user) {
      return res.status(400).json({ success: false, message: 'Invalid or expired reset token' });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    user.password = hashedPassword;
    user.passwordResetToken = undefined;
    user.passwordResetExpires = undefined;
    await user.save();

    res.status(200).json({
      success: true,
      message: 'Password reset successfully'
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  register,
  verifyEmail,
  login,
  socialAuth,
  forgotPassword,
  resetPassword
};
