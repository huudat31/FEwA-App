const User = require('../models/User');
const UserSubject = require('../models/UserSubject');

// @desc    Get current user profile (Populated)
// @route   GET /api/users/me
// @access  Private
const getMe = async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id).select('-password -emailVerifyToken -passwordResetToken').populate('school');
    
    // Find subjects linked to user
    const userSubjects = await UserSubject.find({ user: user._id }).populate('subject');
    const subjects = userSubjects.map(us => us.subject);

    res.status(200).json({
      success: true,
      data: {
        ...user.toJSON(),
        subjects
      }
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Update current user profile (Onboarding)
// @route   PATCH /api/users/me
// @access  Private
const updateMe = async (req, res, next) => {
  try {
    const { avatarUrl, school, dateOfBirth, setupCompleted, subjects } = req.body;

    // Build update object
    const updateData = {};
    if (avatarUrl !== undefined) updateData.avatarUrl = avatarUrl;
    if (school !== undefined) updateData.school = school;
    if (dateOfBirth !== undefined) updateData.dateOfBirth = dateOfBirth;
    if (setupCompleted !== undefined) updateData.setupCompleted = setupCompleted;

    const updatedUser = await User.findByIdAndUpdate(
      req.user.id,
      updateData,
      { new: true, runValidators: true }
    ).select('-password -emailVerifyToken -passwordResetToken').populate('school');

    // Sync subjects if provided
    let finalSubjects = [];
    if (subjects && Array.isArray(subjects)) {
      // Remove old subjects
      await UserSubject.deleteMany({ user: req.user.id });
      
      // Insert new subjects mapping
      if (subjects.length > 0) {
        const subjectInserts = subjects.map(subjectId => ({ user: req.user.id, subject: subjectId }));
        await UserSubject.insertMany(subjectInserts);
      }
    }

    // Return populated data
    const userSubjects = await UserSubject.find({ user: req.user.id }).populate('subject');
    finalSubjects = userSubjects.map(us => us.subject);

    res.status(200).json({
      success: true,
      data: {
        ...updatedUser.toJSON(),
        subjects: finalSubjects
      }
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getMe,
  updateMe
};
