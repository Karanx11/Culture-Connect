const admin = require("../config/firebase");
const jwt = require("jsonwebtoken");
const User = require("../models/User");

// Login / Register
exports.googleAuth = async (req, res) => {
  try {
    const { token, name, email } = req.body;

    // Verify Firebase token
    const decoded = await admin.auth().verifyIdToken(token);

    if (!decoded) {
      return res.status(401).json({ message: "Unauthorized" });
    }

    // Check if user exists
    let user = await User.findOne({ email });

    if (!user) {
      user = await User.create({
        name,
        email,
      });
    }

    // Create JWT
    const jwtToken = jwt.sign(
      { id: user._id },
      process.env.JWT_SECRET,
      { expiresIn: "7d" }
    );

    res.json({
      user,
      token: jwtToken,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};