const School = require('../models/School');
const Subject = require('../models/Subject');

const initialSubjects = [
  { name: 'Math', slug: 'math' },
  { name: 'Science', slug: 'science' },
  { name: 'History', slug: 'history' },
  { name: 'Literature', slug: 'literature' },
  { name: 'Physics', slug: 'physics' },
  { name: 'Geography', slug: 'geography' },
  { name: 'Economics', slug: 'economics' },
  { name: 'Art History', slug: 'art-history' }
];

const seedData = async () => {
  try {
    const subjectCount = await Subject.countDocuments();
    if (subjectCount === 0) {
      await Subject.insertMany(initialSubjects);
      console.log('Subjects seeded successfully.');
    }

    const schoolCount = await School.countDocuments();
    if (schoolCount === 0) {
      // Create a default school just for testing onboarding if needed
      await School.create({ name: 'Default High School', slug: 'default-high-school' });
      console.log('School seeded successfully.');
    }
  } catch (error) {
    console.error('Seeding error:', error);
  }
};

module.exports = seedData;
