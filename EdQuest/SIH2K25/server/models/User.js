const mongoose = require('mongoose');
const userSchema = new mongoose.Schema({
    name: { type: String, required: true }, 
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    language: { type: String },
    className: { type: String },},
    {timestamps: true});
    const User = mongoose.model('User', userSchema);
module.exports = User;
