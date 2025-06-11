import express from 'express';
import { updateIssueStatus, TakeIssue, searchByCategory, searchByLocation } from '../controllers/repairTeamController.js';
// Add any other necessary authentication or middleware imports here
// import { verifyTeamMember } from '../middleware/authMiddleware.js'; // Example

const router = express.Router();

// Route to update issue status
// Assuming :id is the issueId
// Add verifyTeamMember middleware if you have role-based access control
router.put('/issues/:id/status', /* verifyTeamMember, */ updateIssueStatus);

// You might want to add other routes from repairTeamController here too, for example:
router.post('/issues/take', /* verifyTeamMember, */ TakeIssue); // Example route for TakeIssue
router.get('/issues/category', /* verifyTeamMember, */ searchByCategory);
router.get('/issues/location', /* verifyTeamMember, */ searchByLocation);


export default router;