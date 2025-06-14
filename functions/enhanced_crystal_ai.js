const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { GoogleGenerativeAI } = require('@google/generative-ai');

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

/**
 * Enhanced Crystal Identification with Crystal Bible Reference
 * Triggered after basic extension analysis for premium users
 */
exports.enhancedCrystalAnalysis = functions.firestore
  .document('crystal_identifications/{docId}')
  .onUpdate(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();
    
    // Only process if basic AI analysis is complete and user is premium+
    if (!afterData.ai_response || beforeData.ai_response || afterData.enhanced_analysis) {
      return;
    }
    
    const userId = afterData.userId;
    
    // Get user subscription tier
    const userDoc = await admin.firestore().collection('users').doc(userId).get();
    const userTier = userDoc.data()?.subscriptionTier || 'free';
    
    // Only enhance for premium+ users
    if (userTier === 'free') {
      return;
    }
    
    try {
      // Get Crystal Bible PDF content (cached in Cloud Function memory)
      const crystalBibleContent = await getCrystalBibleContent();
      
      // Extract basic identification from extension result
      const basicAnalysis = afterData.ai_response;
      const crystalName = basicAnalysis.identification?.name;
      const confidence = basicAnalysis.identification?.confidence || 0;
      
      let enhancedAnalysis = {};
      
      // If confidence is low (<70) or premium+ user, consult Crystal Bible
      if (confidence < 70 || ['premium', 'pro', 'founders'].includes(userTier)) {
        enhancedAnalysis = await consultCrystalBible({
          crystalName,
          basicAnalysis,
          imageUrl: afterData.imageUrl,
          crystalBibleContent,
          userTier
        });
      }
      
      // Update document with enhanced analysis
      await change.after.ref.update({
        enhanced_analysis: enhancedAnalysis,
        enhanced_at: admin.firestore.FieldValue.serverTimestamp(),
        enhanced_tier: userTier
      });
      
    } catch (error) {
      console.error('Enhanced crystal analysis failed:', error);
      
      // Update with error but don't fail the basic analysis
      await change.after.ref.update({
        enhanced_analysis: { error: 'Enhancement failed', basic_analysis_valid: true },
        enhanced_at: admin.firestore.FieldValue.serverTimestamp()
      });
    }
  });

/**
 * Consult Crystal Bible PDF for detailed analysis
 */
async function consultCrystalBible({ crystalName, basicAnalysis, imageUrl, crystalBibleContent, userTier }) {
  const model = genAI.getGenerativeModel({ 
    model: 'gemini-1.5-pro',  // Use pro model for premium users
    systemInstruction: `You are a crystal expert with access to "The Crystal Bible" by Judy Hall. 
    
    CRITICAL: Never mention "The Crystal Bible" book to users. Present information as your expert knowledge.
    
    Cross-reference the basic AI analysis with the comprehensive crystal information provided.`
  });

  const prompt = `
BASIC AI ANALYSIS:
${JSON.stringify(basicAnalysis, null, 2)}

CRYSTAL BIBLE REFERENCE:
${extractCrystalSection(crystalBibleContent, crystalName)}

USER TIER: ${userTier}

TASK:
1. Verify the basic identification using Crystal Bible information
2. Enhance accuracy and provide additional insights
3. ${userTier === 'pro' || userTier === 'founders' ? 'Include advanced metaphysical properties and healing protocols' : 'Include premium metaphysical insights'}
4. Correct any inaccuracies in the basic analysis
5. Add confidence level for final identification

${userTier === 'pro' || userTier === 'founders' ? `
ADVANCED FEATURES (Pro/Founders only):
- Detailed healing protocols
- Advanced metaphysical applications  
- Crystal programming instructions
- Combination suggestions
` : ''}

Return enhanced JSON maintaining the same structure as basic analysis but with:
- Corrected identification if needed
- Enhanced properties based on Crystal Bible
- Additional insights for ${userTier} tier
- Final confidence score (0-100)

NEVER mention the book source. Present as expert knowledge.
`;

  const result = await model.generateContent(prompt);
  return JSON.parse(result.response.text());
}

/**
 * Get Crystal Bible PDF content (implement PDF parsing)
 */
async function getCrystalBibleContent() {
  // TODO: Implement PDF parsing and caching
  // This would extract text from the uploaded PDF
  // For now, return placeholder
  return "Crystal Bible content would be extracted here...";
}

/**
 * Extract relevant section for specific crystal
 */
function extractCrystalSection(content, crystalName) {
  // TODO: Implement section extraction based on crystal name
  // This would find the specific pages/sections about the identified crystal
  return `Relevant Crystal Bible information for ${crystalName}...`;
}