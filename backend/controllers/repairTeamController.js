import Issues from "../models/Issue.js";
import User from "../models/User.js";

export const getIssues = async (req, res) => {
    try {
        const issues = await Issues.find().sort({ createdAt: -1 });
        return res.status(200).json({
            success: true,
            message: "All issues retrieved successfully for team",
            data: issues
        });
    } catch (error) {
        console.error('Error in getIssues (repairTeamController):', error);
        res.status(500).json({
            success: false,
            message: "Failed to retrieve issues for team",
            error: error.message
        });
    }
};
import mongoose from "mongoose"; // Import mongoose for ObjectId validation
export const TakeIssue = async (req, res) => {
    try {
        const { issueId, description, status } = req.body;
        const issue = await Issues.findById(issueId);
        if (!issue) {
            return res.status(404).json({
                success: false,
                message: "Issue Not Found!!!"
            });
        }
        issue.description = description;
        issue.status = status;
        await issue.save();

        return res.status(200).json({
            success: true,
            message: "Issue updated successfully!!!",
            updatedIssue: issue
        });
    } catch (error) {
        return res.status(500).json({
            success: false,
            message: "Server Error",
            error: error.message
        });
    }
};
export const searchByCategory = async (req, res) => {
    const { category } = req.query;
    try {
        if (!category) {
            return res.status(400).json({
                success: false,
                message: "Category is required!"
            });
        }
        const issues = await Issues.find({
            category: { $regex: category, $options: "i" } 
        }).sort({ createdAt: -1 });

        return res.status(200).json({
            success: true,
            message: "Successfully retrieved issues by category",
            data: issues
        });
    } catch (error) {
        res.status(500).json({ success: false, message: "Server Error!", error: error.message });
    }
};

export const searchByLocation = async (req, res) => {
    const { location } = req.query;
    try {
        if (!location) {
            return res.status(400).json({
                success: false,
                message: "Location is required!"
            });
        }
        const issues = await Issues.find({
            location: { $regex: location, $options: "i" }
        }).sort({ createdAt: -1 });

        return res.status(200).json({
            success: true,
            message: "Successfully filtered by location",
            data: issues
        });
    } catch (error) {
        res.status(500).json({ success: false, message: "Server Error!", error: error.message });
    }
};

export const updateIssueStatus = async (req, res) => {
    try {
        const { id } = req.params; // Get ID from URL parameters
        const { status, notes } = req.body;

        if (!mongoose.Types.ObjectId.isValid(id)) {
            return res.status(400).json({
                success: false,
                message: "Invalid issue ID format"
            });
        }

        if (!status) {
            return res.status(400).json({
                success: false,
                message: "Status is required"
            });
        }

        const issue = await Issues.findById(id);

        if (!issue) {
            return res.status(404).json({
                success: false,
                message: "Issue not found"
            });
        }

        issue.status = status;
        if (notes) {
            issue.lastStatusUpdateNotes = notes; // Example: using a dedicated field
        }

        const updatedIssue = await issue.save();

        return res.status(200).json({
            success: true,
            message: "Issue status updated successfully",
            data: updatedIssue
        });

    } catch (error) {
        console.error('Error in updateIssueStatus (repairTeamController):', error);
        res.status(500).json({
            success: false,
            message: "Failed to update issue status",
            error: error.message
        });
    }
};
