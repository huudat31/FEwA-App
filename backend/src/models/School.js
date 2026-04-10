const mongoose = require('mongoose');

const schoolSchema = new mongoose.Schema({
  name: { type: String, required: true },
  slug: { type: String, unique: true }
}, { timestamps: true });

module.exports = mongoose.model('School', schoolSchema);
