const mongoose = require('mongoose');

const userSubjectSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  subject: { type: mongoose.Schema.Types.ObjectId, ref: 'Subject', required: true }
}, { timestamps: true });

userSubjectSchema.index({ user: 1, subject: 1 }, { unique: true });

module.exports = mongoose.model('UserSubject', userSubjectSchema);
