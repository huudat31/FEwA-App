const mongoose = require('mongoose');

const userAuthProviderSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  provider: { type: String, required: true, enum: ['google', 'apple', 'facebook'] },
  providerId: { type: String, required: true },
  email: { type: String },
  name: { type: String },
  avatarUrl: { type: String }
}, { timestamps: true });

userAuthProviderSchema.index({ user: 1, provider: 1, providerId: 1 }, { unique: true });

module.exports = mongoose.model('UserAuthProvider', userAuthProviderSchema);
