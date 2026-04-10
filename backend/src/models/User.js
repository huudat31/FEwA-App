const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  email: { type: String, unique: true, required: true },
  password: { type: String }, // optional cho OAuth
  avatarUrl: { type: String },
  school: { type: mongoose.Schema.Types.ObjectId, ref: 'School' },
  dateOfBirth: { type: Date },
  setupCompleted: { type: Boolean, default: false },
  role: { type: String, enum: ['student', 'admin'], default: 'student' },

  // Verification and password reset
  isEmailVerified: { type: Boolean, default: false },
  emailVerifyToken: { type: String },
  passwordResetToken: { type: String },
  passwordResetExpires: { type: Date }
}, { timestamps: true });

module.exports = mongoose.model('User', userSchema);
