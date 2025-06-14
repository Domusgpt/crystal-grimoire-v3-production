# CrystalGrimoire.com Domain Transfer Guide

## Current Status
- **Domain**: crystalgrimoire.com
- **Current Registrar**: GoDaddy
- **Target**: Firebase Hosting + Custom Domain
- **Status**: Ready for transfer

## Step-by-Step Transfer Process

### Phase 1: Prepare Firebase Hosting

1. **Verify Firebase Project**
   ```bash
   firebase projects:list
   firebase use crystalgrimoire-production
   ```

2. **Ensure App is Deployed**
   ```bash
   flutter build web --release
   firebase deploy --only hosting
   ```

3. **Verify Current Hosting URL**
   - Default URL: `https://crystalgrimoire-production.web.app`
   - Ensure app loads and functions correctly

### Phase 2: GoDaddy DNS Configuration

1. **Login to GoDaddy**
   - Go to: https://dashboard.godaddy.com/venture?domainName=crystalgrimoire.com&referrer=my-products
   - Login with your credentials

2. **Access DNS Management**
   - Click on your domain `crystalgrimoire.com`
   - Go to "DNS" → "Manage DNS"
   - You'll see current DNS records

3. **Backup Current DNS Records**
   - Screenshot all existing records
   - Note down all A records, CNAME records, etc.
   - **IMPORTANT**: Save this information before making changes

4. **Update DNS Records**
   
   **Remove existing A records for @ and www (if any)**
   
   **Add Firebase A Records:**
   ```
   Type: A
   Host: @
   Points to: 151.101.1.195
   TTL: 600 (or default)
   ```
   
   ```
   Type: A
   Host: @
   Points to: 151.101.65.195
   TTL: 600 (or default)
   ```
   
   **Add CNAME Record:**
   ```
   Type: CNAME
   Host: www
   Points to: crystalgrimoire-production.web.app
   TTL: 600 (or default)
   ```

5. **Save DNS Changes**
   - GoDaddy will show a warning about changes
   - Confirm and save all changes
   - Changes can take 24-48 hours to propagate

### Phase 3: Configure Firebase Custom Domain

1. **Open Firebase Console**
   - Go to: https://console.firebase.google.com
   - Select `crystalgrimoire-production` project

2. **Add Custom Domain**
   - Go to Hosting → Domains
   - Click "Add custom domain"
   - Enter: `crystalgrimoire.com`

3. **Domain Verification**
   Firebase will provide verification options:
   
   **Option A: DNS Verification (Recommended)**
   - Firebase will provide a TXT record
   - Add this TXT record in GoDaddy DNS management
   - Wait for verification (can take a few minutes to hours)
   
   **Option B: File Upload Verification**
   - Download verification file from Firebase
   - Upload to your website root
   - Less reliable, use DNS method

4. **Add www Subdomain**
   - After main domain is verified
   - Add another custom domain: `www.crystalgrimoire.com`
   - This will automatically redirect to main domain

### Phase 4: SSL Certificate Provisioning

1. **Automatic SSL Setup**
   - Firebase automatically provisions SSL certificates
   - This process takes 24-48 hours after domain verification
   - You'll receive email notifications about status

2. **Monitor Certificate Status**
   - Check Firebase Console → Hosting → Domains
   - Status should show "Connected" when complete
   - SSL certificate will show "Active"

### Phase 5: Verification and Testing

1. **DNS Propagation Check**
   - Use online tools: whatsmydns.net
   - Check that crystalgrimoire.com points to Firebase IPs
   - Test from multiple locations globally

2. **Website Functionality Test**
   ```bash
   # Test main domain
   curl -I https://crystalgrimoire.com
   
   # Test www redirect
   curl -I https://www.crystalgrimoire.com
   ```

3. **Full Application Test**
   - Visit https://crystalgrimoire.com
   - Test user registration/login
   - Test payment processing
   - Test profile functionality
   - Verify all features work on custom domain

### Phase 6: Production Configuration

1. **Update Firebase Configuration**
   - Ensure Firebase keys are production-ready
   - Update any hardcoded URLs in the app
   - Test authentication flows

2. **Update Stripe Configuration**
   - Add crystalgrimoire.com to allowed domains
   - Update success/cancel URLs to use custom domain
   - Test payment processing on new domain

3. **Analytics and Monitoring**
   - Update Google Analytics property (if used)
   - Configure Firebase Analytics for new domain
   - Set up monitoring and alerts

## Troubleshooting

### Common Issues

**DNS Not Propagating**
- Wait 24-48 hours for global propagation
- Clear browser cache and DNS cache
- Test from different devices/networks

**SSL Certificate Issues**
- Ensure DNS records are correct
- Wait for automatic provisioning
- Contact Firebase support if stuck

**Domain Verification Fails**
- Double-check TXT record in GoDaddy
- Wait longer for DNS propagation
- Try file verification method

**App Not Loading**
- Verify Firebase deployment is current
- Check browser console for errors
- Ensure all assets load from custom domain

### Emergency Rollback

If something goes wrong:

1. **Restore GoDaddy DNS**
   - Use the DNS backup you created
   - Restore original A records and CNAME records
   - Remove Firebase DNS records

2. **Remove Firebase Custom Domain**
   - Go to Firebase Console → Hosting → Domains
   - Remove custom domain
   - App will still work on .web.app URL

## Timeline Expectations

| Phase | Duration | Notes |
|-------|----------|-------|
| DNS Changes | Immediate | Changes saved in GoDaddy |
| DNS Propagation | 2-24 hours | Global DNS update |
| Domain Verification | 1-6 hours | Firebase verification |
| SSL Certificate | 24-48 hours | Automatic provisioning |
| Full Activation | 48-72 hours | Complete process |

## Post-Transfer Checklist

- [ ] crystalgrimoire.com loads correctly
- [ ] www.crystalgrimoire.com redirects properly
- [ ] SSL certificate is active (green lock)
- [ ] User authentication works
- [ ] Payment processing functions
- [ ] All app features operational
- [ ] Analytics tracking updated
- [ ] SEO redirects configured (if needed)

## Support Contacts

**Firebase Support**
- Firebase Console → Support
- Firebase documentation: firebase.google.com/docs/hosting

**GoDaddy Support**  
- GoDaddy Help Center
- Phone support available 24/7

**Domain Transfer Status**
- Current: GoDaddy DNS → Firebase Hosting
- Expected completion: 48-72 hours after DNS changes
- Status: Ready to begin transfer process

---

**IMPORTANT NOTES:**
1. **Backup everything** before making changes
2. **Test thoroughly** on staging before production
3. **Plan for 48-72 hour transition period**
4. **Have rollback plan ready** in case of issues
5. **Notify users** of potential temporary downtime