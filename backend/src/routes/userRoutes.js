const express = require('express');
const joi = require('joi');
const { validateJoi } = require('../middleware/validate');
const { authJWT } = require('../middleware/auth');
const { getMe, updateMe } = require('../controllers/userController');

const router = express.Router();

const updateMeSchema = joi.object({
  avatarUrl: joi.string().uri().allow(null, ''),
  school: joi.string().allow(null, ''), // Mongoose ObjectId string
  dateOfBirth: joi.date().iso().allow(null, ''),
  setupCompleted: joi.boolean(),
  subjects: joi.array().items(joi.string())
});

router.use(authJWT);

router.get('/me', getMe);
router.patch('/me', validateJoi(updateMeSchema), updateMe);

module.exports = router;
