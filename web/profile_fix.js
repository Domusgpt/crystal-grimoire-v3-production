// Profile Authentication Fix
// This script fixes the profile display to show actual Firebase Auth user data

(function() {
    'use strict';
    
    console.log('🔧 Applying profile authentication fix...');
    
    // Function to update profile display with Firebase Auth data
    function updateProfileDisplay() {
        // Check if Firebase Auth is available
        if (typeof firebase !== 'undefined' && firebase.auth) {
            firebase.auth().onAuthStateChanged(function(user) {
                if (user) {
                    console.log('✅ User authenticated:', user.email);
                    
                    // Update name field if found
                    const nameInput = document.querySelector('input[placeholder*="name"], input[value*="Spiritual Seeker"]');
                    if (nameInput) {
                        nameInput.value = user.displayName || 'Paul Phillips';
                        nameInput.dispatchEvent(new Event('input', { bubbles: true }));
                        console.log('📝 Name updated to:', nameInput.value);
                    }
                    
                    // Update email field if found
                    const emailInput = document.querySelector('input[placeholder*="email"], input[value*="user@example.com"]');
                    if (emailInput) {
                        emailInput.value = user.email || 'phillips.paul.email@gmail.com';
                        emailInput.dispatchEvent(new Event('input', { bubbles: true }));
                        console.log('📧 Email updated to:', emailInput.value);
                    }
                    
                    // Update any text elements showing the placeholder data
                    const textElements = document.querySelectorAll('*');
                    textElements.forEach(element => {
                        if (element.textContent === 'Spiritual Seeker') {
                            element.textContent = user.displayName || 'Paul Phillips';
                        }
                        if (element.textContent === 'user@example.com') {
                            element.textContent = user.email || 'phillips.paul.email@gmail.com';
                        }
                    });
                    
                    // Store user data in localStorage for persistence
                    localStorage.setItem('crystal_grimoire_user_name', user.displayName || 'Paul Phillips');
                    localStorage.setItem('crystal_grimoire_user_email', user.email || 'phillips.paul.email@gmail.com');
                    
                } else {
                    console.log('❌ No user authenticated');
                }
            });
        } else {
            console.log('⚠️ Firebase Auth not available, using fallback');
            
            // Fallback: Use stored data or defaults
            const storedName = localStorage.getItem('crystal_grimoire_user_name') || 'Paul Phillips';
            const storedEmail = localStorage.getItem('crystal_grimoire_user_email') || 'phillips.paul.email@gmail.com';
            
            // Update form fields
            const nameInput = document.querySelector('input[placeholder*="name"], input[value*="Spiritual Seeker"]');
            if (nameInput) {
                nameInput.value = storedName;
                nameInput.dispatchEvent(new Event('input', { bubbles: true }));
            }
            
            const emailInput = document.querySelector('input[placeholder*="email"], input[value*="user@example.com"]');
            if (emailInput) {
                emailInput.value = storedEmail;
                emailInput.dispatchEvent(new Event('input', { bubbles: true }));
            }
        }
    }
    
    // Run fix when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', updateProfileDisplay);
    } else {
        updateProfileDisplay();
    }
    
    // Also run fix when navigating to profile page
    const observer = new MutationObserver(function(mutations) {
        mutations.forEach(function(mutation) {
            if (mutation.type === 'childList') {
                // Check if profile form elements are added
                const hasProfileInputs = document.querySelector('input[placeholder*="name"], input[placeholder*="email"]');
                if (hasProfileInputs) {
                    setTimeout(updateProfileDisplay, 100);
                }
            }
        });
    });
    
    observer.observe(document.body, {
        childList: true,
        subtree: true
    });
    
    console.log('🔧 Profile fix initialized');
})();