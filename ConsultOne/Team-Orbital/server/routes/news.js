const express = require("express");
const router = express.Router();
const axios = require("axios");

const API_KEY = process.env.GNEWS_API_KEY;

router.get("/", async (req, res) => {

    try {

        if (!API_KEY) {
            return res.status(500).json({
                message: "API key not configured"
            });
        }

        const response = await axios.get(
            "https://gnews.io/api/v4/top-headlines",
            {
                params: {
                    country: "in",
                    category: "health",
                    lang: "en",
                    apikey: API_KEY
                }
            }
        );

        res.json(response.data.articles);

    } catch (error) {

        console.error("News fetch error:", error.response?.data || error.message);

        res.status(500).json({
            message: "Failed to fetch news"
        });

    }

});

module.exports = router;