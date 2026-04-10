const express = require('express');
const joi = require('joi');
const { validateJoi } = require('../middleware/validate');
const {
  register,
  verifyEmail,
  login,
  socialAuth,
  forgotPassword,
  resetPassword
} = require('../controllers/authController');

const router = express.Router();

const registerSchema = joi.object({
  email: joi.string().email().required(),
  password: joi.string().min(6).required()
});

const verifyEmailSchema = joi.object({
  token: joi.string().required()
});

const loginSchema = joi.object({
  email: joi.string().email().required(),
  password: joi.string().required()
});

const socialAuthSchema = joi.object({
  providerId: joi.string().required(),
  email: joi.string().email().allow(null, ''),
  name: joi.string().allow(null, ''),
  avatarUrl: joi.string().uri().allow(null, '')
});

const forgotPasswordSchema = joi.object({
  email: joi.string().email().required()
});

const resetPasswordSchema = joi.object({
  token: joi.string().required(),
  password: joi.string().min(6).required()
});

router.post('/register', validateJoi(registerSchema), register);
router.post('/verify-email', validateJoi(verifyEmailSchema), verifyEmail);
router.post('/login', validateJoi(loginSchema), login);
router.post('/auth/:provider', validateJoi(socialAuthSchema), socialAuth);
router.post('/forgot-password', validateJoi(forgotPasswordSchema), forgotPassword);
router.post('/reset-password', validateJoi(resetPasswordSchema), resetPassword);

module.exports = router;
