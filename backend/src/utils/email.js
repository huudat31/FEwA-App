const nodemailer = require('nodemailer');

const sendEmail = async (options) => {
  if (process.env.NODE_ENV !== 'production' && !process.env.NODEMAILER_USER) {
    // In dev mode without credentials, just log the email contents
    console.log('--- DEVELOPMENT MODE EMAIL START ---');
    console.log(`To: ${options.email}`);
    console.log(`Subject: ${options.subject}`);
    console.log(`Text: ${options.message}`);
    console.log('--- DEVELOPMENT MODE EMAIL END ---');
    return;
  }

  const transporter = nodemailer.createTransport({
    host: process.env.EMAIL_HOST || 'smtp.mailtrap.io',
    port: process.env.EMAIL_PORT || 2525,
    auth: {
      user: process.env.NODEMAILER_USER,
      pass: process.env.NODEMAILER_PASS
    }
  });

  const mailOptions = {
    from: 'Onboarding API <noreply@onboarding.api>',
    to: options.email,
    subject: options.subject,
    text: options.message
  };

  await transporter.sendMail(mailOptions);
};

module.exports = sendEmail;
