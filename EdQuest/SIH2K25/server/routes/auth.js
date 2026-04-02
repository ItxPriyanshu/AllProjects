const express = require("express");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const User = require("../models/User");

const authRouter = express.Router();

// SIGNUP
authRouter.post("/signup", async (req, res) => {
  try {
    const { name, email, password, language, className } = req.body;

    if (!name || !email || !password || !language || !className) {
      return res.status(400).json({ message: "All fields are required" });
    }

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: "User already exists" });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const newUser = new User({
      name,
      email,
      password: hashedPassword,
      language,
      className,
    });

    await newUser.save();

    const token = jwt.sign(
      { id: newUser._id.toString() },
      process.env.JWT_SECRET || "secretkey",
      { expiresIn: "7d" }
    );

    console.log("Signup successful for:", email);

    return res.status(201).json({
      message: "User created successfully",
      token,
      user: {
        id: newUser._id.toString(),
        name: newUser.name || "",
        email: newUser.email || "",
        language: newUser.language || "",
        className: newUser.className || "",
      },
    });
  } catch (err) {
    console.error("Signup error:", err);
    return res.status(500).json({ message: "Internal server error" });
  }
});

// LOGIN
authRouter.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email });
    if (!user) return res.status(400).json({ message: "Invalid email or password" });

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(400).json({ message: "Invalid email or password" });

    const token = jwt.sign(
      { id: user._id.toString() },
      process.env.JWT_SECRET || "secretkey",
      { expiresIn: "7d" }
    );

    return res.json({
      token,
      user: {
        id: user._id.toString(),
        name: user.name || "",
        email: user.email || "",
        language: user.language || "",
        className: user.className || "",
      },
    });
  } catch (err) {
    console.error("Login error:", err);
    return res.status(500).json({ message: "Internal server error" });
  }
});

// GET USER PROFILE
authRouter.get("/user", async (req, res) => {
  try {
    const token = req.headers.authorization?.split(" ")[1];
    if (!token) return res.status(401).json({ message: "No token provided" });

    const decoded = jwt.verify(token, process.env.JWT_SECRET || "secretkey");
    const user = await User.findById(decoded.id).select("-password");

    if (!user) return res.status(404).json({ message: "User not found" });

    return res.json(user);
  } catch (err) {
    console.error("Get user error:", err);
    return res.status(500).json({ message: "Internal server error" });
  }
});

module.exports = authRouter;
