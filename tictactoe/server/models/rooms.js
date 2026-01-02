const mongoose = require('mongoose');
const playerSchema = require('./player');

const roomSchema = new mongoose.Schema({
  occupancy: {
    type: Number,
    default: 2,
  },
  maxRounds: {
    type: Number,
    default: 6,
  },
  currentRound: {
    type: Number,
    default: 1,
  },

  players: [playerSchema],

  // 🔑 ADD THESE
  turn: {
    type: playerSchema,
    required: true,
  },
  turnIndex: {
    type: Number,
    default: 0,
  },
});

module.exports = mongoose.model('Room', roomSchema);
