# ARCHIVED SERVICES

These services have been archived because they're redundant, broken, or cause compilation conflicts.

## Why Archived?
- **Multiple conflicting implementations** of the same functionality
- **Broken/incomplete services** that don't actually work
- **Import conflicts** between similar classes
- **Compilation errors** due to missing dependencies

## Working Services (NOT archived)
- `ai_service.dart` - **WORKS** - Gemini API integration for crystal ID
- `collection_service.dart` - **WORKS** - Crystal collection management  
- `storage_service.dart` - **WORKS** - Local data persistence
- `enhanced_payment_service.dart` - **WORKS** - Stripe payment processing
- `marketplace_service.dart` - **WORKS** - Firebase marketplace functionality

## Archived Services
- `unified_ai_service.dart` - Conflicts with ai_service.dart
- `unified_data_service.dart` - Redundant with storage_service.dart
- `parse_operator_service.dart` - Overengineered, missing dependencies
- `exoditical_validation_service.dart` - Conflicts with parse_operator
- `firebase_ai_service.dart` - Redundant with ai_service.dart
- `enhanced_ai_service.dart` - Redundant with ai_service.dart
- `firebase_extensions_service.dart` - Incomplete implementation
- `firebase_functions_service.dart` - Redundant with firebase_ai_service.dart
- `firebase_service_new.dart` - Redundant with existing firebase services
- `llm_service.dart` - Redundant with ai_service.dart
- `openai_service.dart` - Handled by ai_service.dart multi-provider
- `offline_crystal_service.dart` - Limited functionality, not needed

## Result
- **Before**: 15+ conflicting AI/LLM services causing compilation errors
- **After**: 1 working AI service with multi-provider support (Gemini, OpenAI, etc.)
- **Status**: ✅ Compiles successfully, ✅ Crystal identification works