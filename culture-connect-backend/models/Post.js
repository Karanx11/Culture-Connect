const mongoose = require("mongoose");

const postSchema = new mongoose.Schema(
  {
    user_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    media_url: {
      type: String,
      required: true,
    },
    caption: String,
    category: {
      type: String,
      enum: ["Festival", "Food", "Tradition", "Clothing", "Language"],
    },
    tags: [String],
    location: String,
  },
  { timestamps: true }
);

module.exports = mongoose.model("Post", postSchema);