# Later MVP - Master Implementation Plan

## Executive Summary

This master plan outlines the complete MVP development roadmap for the Later app—a flexible, offline-first organizer combining tasks, notes, and lists. The implementation is divided into **two major phases** that incrementally build from local-only functionality to a full-featured cloud-sync application.

**Total Timeline**: 7-9 weeks
**Team Size**: 1 developer (can scale with parallel work)
**Tech Stack**: Flutter + Hive (local) + Supabase (backend)

## Vision & Philosophy

**"Works How You Think"** - Later adapts to users' natural workflow rather than forcing rigid structures.

### Core Principles
1. **Offline-First**: Full functionality without internet, sync is enhancement
2. **Local-First**: Data lives on device, cloud is backup/sync layer
3. **Zero Friction**: Quick capture in <3 seconds, auto-save everything
4. **Progressive Disclosure**: Simple surface, power underneath
5. **Code-First Infrastructure**: Version-controlled backend via Supabase CLI

## Phase Overview

### Phase 1: Foundation & Local-First Core (3-4 weeks)
**Goal**: Build standalone offline app with complete core functionality

**What Users Can Do:**
- ✅ Create tasks, notes, and lists locally
- ✅ Organize items into spaces
- ✅ Quick capture with keyboard shortcuts
- ✅ Edit, complete, and delete items
- ✅ Switch between spaces instantly
- ✅ Works 100% offline, no account required
- ✅ Data persists across app restarts

**Technical Deliverables:**
- Flutter project with Material 3 design system
- Hive local database with item/space models
- Repository pattern for data abstraction
- Provider state management
- Core UI components (cards, buttons, inputs, FAB)
- Responsive layouts (mobile, tablet, desktop)
- Quick capture modal with smart type detection
- Space management (create, edit, switch)
- Comprehensive widget tests

**Status**: Ready to implement
**Plan Document**: `mvp-phase-1-foundation.md`

---

### Phase 2: Supabase Backend & Sync (4-5 weeks)
**Goal**: Add cloud backup, multi-device sync, and authentication

**What Users Can Do:**
- ✅ Create account (email/password or OAuth)
- ✅ Sync data across devices automatically
- ✅ Work offline, sync when online
- ✅ Migrate existing local data to cloud
- ✅ Reset password via email
- ✅ Sign out and data persists in cloud

**Technical Deliverables:**
- Supabase CLI setup with local development
- Database schema with Row-Level Security
- Remote repositories for Supabase operations
- Sync engine with conflict resolution
- Auth flows (sign up, sign in, OAuth, password reset)
- Sync queue with retry logic
- Migration service (local → cloud)
- Sync status indicators
- Production deployment configuration
- Integration tests for sync operations

**Status**: Blocked by Phase 1
**Plan Document**: `mvp-phase-2-supabase-sync.md`

---

## Detailed Timeline

### Weeks 1-4: Phase 1 Implementation

**Week 1: Foundation**
- Days 1-2: Project setup, dependencies, folder structure
- Days 3-4: Design system implementation (colors, typography, theme)
- Days 5-7: Hive setup, models, repository layer

**Week 2: Core Features**
- Days 8-9: State management (providers)
- Days 10-11: Item card component with variants
- Days 12-14: Home screen, navigation, space switcher

**Week 3: Key Features**
- Days 15-16: Quick capture modal with type detection
- Days 17-18: Item detail screen with auto-save
- Days 19-21: Item operations (complete, edit, delete)

**Week 4: Polish**
- Days 22-23: Space management (create, edit, delete)
- Days 24-25: Loading states, empty states, error handling
- Days 26-28: Accessibility audit, performance optimization, testing

**Phase 1 Milestone**: Fully functional offline app ready for internal testing

---

### Weeks 5-9: Phase 2 Implementation

**Week 5: Supabase Setup**
- Days 29-30: Supabase CLI installation, local stack setup
- Days 31-32: Database schema design and migrations
- Days 33-35: Row-Level Security policies, TypeScript type generation

**Week 6: Client Integration**
- Days 36-37: Flutter Supabase client setup
- Days 38-39: Remote repositories implementation
- Days 40-42: Sync queue and conflict resolution logic

**Week 7: Authentication**
- Days 43-44: Sign up and sign in screens
- Days 45-46: OAuth integration (Google, GitHub)
- Days 47-49: Password reset flow, auth state management

**Week 8: Sync Engine**
- Days 50-51: Initial full sync (cloud → local)
- Days 52-53: Incremental sync and queue processing
- Days 54-56: Local-to-cloud migration for existing users

**Week 9: Production & Testing**
- Days 57-58: Sync UI indicators and status display
- Days 59-60: Production Supabase deployment
- Days 61-63: Integration testing, bug fixes, beta testing

**Phase 2 Milestone**: Full cloud-sync app ready for public beta

---

## Success Metrics

### Phase 1 Metrics
- **Functionality**: All P0 features working offline
- **Performance**: App launch <2s, space switching <200ms, 60fps scrolling
- **Quality**: Zero crashes, 70%+ test coverage, WCAG AA compliance
- **UX**: Quick capture <3s, intuitive navigation, helpful empty states

### Phase 2 Metrics
- **Sync Reliability**: >99% sync success rate
- **Data Safety**: Zero data loss during sync or migration
- **Performance**: Initial sync <10s, incremental sync <3s
- **Security**: RLS audit passed, OAuth flows secure, no data leakage
- **Adoption**: 30%+ of users create accounts and sync

### Combined MVP Metrics (End of Phase 2)
- **User Satisfaction**: 4+ star app store rating
- **Engagement**: Users create 5+ items per week
- **Retention**: 60%+ MAU retention rate
- **Offline Usage**: 40%+ of sessions offline
- **Cross-Device**: 30%+ of users sync across devices

---

## Architecture Overview

### Data Flow Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                          UI Layer                            │
│  (Screens, Widgets, Components)                              │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────────┐
│                     State Management                         │
│  Provider (ItemsProvider, SpacesProvider, AuthProvider)      │
└────────┬──────────────────────────────────────┬─────────────┘
         │                                      │
         ↓                                      ↓
┌──────────────────────┐          ┌─────────────────────────┐
│   Local Repository   │          │   Remote Repository     │
│   (Hive Database)    │◄────────►│   (Supabase Client)     │
└──────────────────────┘          └─────────────────────────┘
         │                                      │
         │                                      │
    [Phase 1]                              [Phase 2]
   Local-Only                          Cloud Sync Layer
```

### Sync Architecture (Phase 2)

```
User Action
    │
    ↓
┌─────────────────────────────────────────┐
│  1. Update Local (Hive) - INSTANT       │ ← Optimistic UI
└─────────────────────────────────────────┘
    │
    ↓
┌─────────────────────────────────────────┐
│  2. Add to Sync Queue                   │
└─────────────────────────────────────────┘
    │
    ↓
┌─────────────────────────────────────────┐
│  3. Background Sync to Supabase         │
│     (when online)                       │
└─────────────────────────────────────────┘
    │
    ├── Success → Remove from queue
    │
    └── Failure → Retry with backoff

On App Launch / Periodic:
┌─────────────────────────────────────────┐
│  1. Fetch updates from Supabase         │
│     (WHERE updated_at > last_sync)      │
└─────────────────────────────────────────┘
    │
    ↓
┌─────────────────────────────────────────┐
│  2. Merge into Local (Hive)             │
│     (Last-Write-Wins conflict resolution)│
└─────────────────────────────────────────┘
    │
    ↓
┌─────────────────────────────────────────┐
│  3. Update last_sync_timestamp          │
└─────────────────────────────────────────┘
```

---

## Technical Stack

### Frontend
- **Framework**: Flutter 3.24+ (Dart 3.5+)
- **UI**: Material 3 with custom design system
- **State Management**: Provider
- **Local Database**: Hive (NoSQL, offline-first)
- **Navigation**: Flutter Navigator 2.0

### Backend (Phase 2)
- **BaaS**: Supabase (free tier)
- **Database**: PostgreSQL (via Supabase)
- **Auth**: Supabase Auth (JWT + OAuth)
- **API**: Supabase REST API (auto-generated)
- **Real-time**: Supabase Realtime (future use)

### DevOps
- **Version Control**: Git + GitHub
- **CI/CD**: GitHub Actions (future)
- **Development**: Supabase CLI with Docker (local stack)
- **Deployment**: Supabase Cloud (production)
- **Testing**: Flutter test framework, widget tests, integration tests

### Key Dependencies
```yaml
# Phase 1
provider: ^6.1.0                # State management
hive: ^2.2.3                    # Local database
hive_flutter: ^1.1.0
uuid: ^4.5.0                    # Generate IDs
intl: ^0.19.0                   # Date formatting
path_provider: ^2.1.4

# Phase 2
supabase_flutter: ^2.8.0        # Supabase client
flutter_dotenv: ^5.1.0          # Environment variables
connectivity_plus: ^6.0.0       # Network detection
retry: ^3.1.0                   # Retry logic
```

---

## Risk Management

### High-Risk Items

**Risk 1: Phase 1 Over-Engineering**
- **Impact**: Delayed Phase 1 completion
- **Mitigation**: Strict MVP scope, avoid "nice-to-haves"
- **Contingency**: Cut non-essential features (e.g., tags, priorities)

**Risk 2: Supabase Free Tier Limits**
- **Impact**: Can't scale beyond 500MB database, 2 projects
- **Mitigation**: Monitor usage, optimize storage, prepare paid upgrade path
- **Contingency**: Migrate to Pro tier ($25/mo) if needed

**Risk 3: Sync Complexity**
- **Impact**: Sync bugs cause data loss or corruption
- **Mitigation**: Thorough testing, conflict logging, rollback capability
- **Contingency**: Disable sync feature, fix bugs, re-enable

**Risk 4: OAuth Configuration**
- **Impact**: OAuth flows don't work on production
- **Mitigation**: Test thoroughly on local + production environments
- **Contingency**: Email/password auth remains functional, fix OAuth post-launch

### Medium-Risk Items

**Risk 5: Performance on Low-End Devices**
- **Impact**: Poor UX on older Android phones
- **Mitigation**: Profile early, optimize rendering, test on real devices
- **Contingency**: Reduce animations, simplify UI, add "lite mode"

**Risk 6: Developer Availability**
- **Impact**: Single developer becomes unavailable
- **Mitigation**: Comprehensive documentation, clean code, modular architecture
- **Contingency**: Pause development, onboard replacement developer

**Risk 7: Design System Implementation**
- **Impact**: UI doesn't match design specs
- **Mitigation**: Reference design tokens, review with designer regularly
- **Contingency**: Iterate on design, accept minor deviations for MVP

---

## Resource Requirements

### Developer Skills Needed
- **Required**: Flutter/Dart, state management (Provider), Hive, Git
- **Phase 2**: Supabase, PostgreSQL, REST APIs, OAuth flows
- **Nice to Have**: UI/UX sensibility, accessibility knowledge, CI/CD

### Development Environment
- **Hardware**: Modern laptop (8GB+ RAM, SSD)
- **Software**:
  - Flutter SDK 3.24+
  - Android Studio or VS Code + Flutter plugins
  - Docker Desktop (Phase 2)
  - Supabase CLI (Phase 2)
  - Git
- **Devices**: iOS simulator, Android emulator, physical device for testing

### Cloud Resources (Phase 2)
- **Supabase Free Tier**:
  - 500MB database storage
  - 2 projects (dev + prod)
  - 50,000 monthly active users
  - 2GB bandwidth
  - Sufficient for MVP and early growth

### Budget Estimate
- **Phase 1**: $0 (all local development)
- **Phase 2 Development**: $0 (Supabase free tier + local dev)
- **Phase 2 Production**: $0-$25/month (start free, upgrade if needed)
- **Total MVP Cost**: $0-$25/month

---

## Quality Assurance Strategy

### Testing Approach

**Unit Tests**
- All models (serialization, validation)
- Repository methods (CRUD operations)
- Utility functions (type detection, date formatting)
- Target: 80%+ coverage for business logic

**Widget Tests**
- All core components (ItemCard, buttons, inputs)
- Critical flows (quick capture, space switcher)
- Target: 70%+ coverage for UI components

**Integration Tests**
- Complete user flows (create item, switch space, sync data)
- Auth flows (sign up, sign in, OAuth)
- Sync scenarios (offline → online, conflict resolution)
- Target: All P0 user stories covered

**Manual Testing**
- Test on real devices (iOS, Android)
- Test on various screen sizes (mobile, tablet, desktop)
- Test with screen readers (TalkBack, VoiceOver)
- Test with poor network conditions
- Test accessibility compliance (WCAG AA)

### Quality Gates

**Phase 1 Exit Criteria**
- ✅ All P0 features functional
- ✅ Zero critical bugs (crashes, data loss)
- ✅ Performance targets met (launch <2s, 60fps)
- ✅ Accessibility audit passed
- ✅ 70%+ test coverage

**Phase 2 Exit Criteria**
- ✅ All Phase 1 criteria remain met
- ✅ Sync reliability >99%
- ✅ Zero data loss in testing
- ✅ RLS security audit passed
- ✅ OAuth flows work on all platforms
- ✅ Beta testing feedback addressed

---

## Deployment Strategy

### Phase 1 Deployment
**Target**: Internal testing only
- Build Android APK and iOS IPA
- Distribute via direct download (not app stores yet)
- Collect feedback from 5-10 internal testers
- Iterate based on feedback

### Phase 2 Deployment

**2A: Alpha Testing (Weeks 5-6)**
- Deploy to internal testers with Supabase dev environment
- Test auth and sync thoroughly
- Fix critical bugs

**2B: Closed Beta (Weeks 7-8)**
- Deploy to Supabase production
- Invite 10-20 external testers
- Monitor sync operations and errors
- Collect feedback via in-app form

**2C: Open Beta (Week 9)**
- Expand to 100+ testers
- Submit to app stores (beta channels)
- Monitor backend performance
- Optimize based on real usage

**2D: Public Launch (Post-MVP)**
- Full app store release (iOS App Store, Google Play)
- Marketing push (Product Hunt, social media)
- Monitor analytics and user feedback
- Rapid iteration on issues

---

## Post-MVP Roadmap (Phase 3+)

### Potential Phase 3: Enhanced Features (4-6 weeks)
- Advanced search with filters
- Natural language processing for quick capture
- Smart date detection (e.g., "tomorrow", "next Friday")
- Bulk operations (select multiple, batch actions)
- Keyboard shortcuts on desktop
- Tag system with colors
- Priority levels
- Recurring tasks

### Potential Phase 4: Collaboration (6-8 weeks)
- Share spaces with other users
- Granular permissions (view, edit, admin)
- Real-time collaborative editing
- Presence indicators
- Activity feed
- Comments on items
- Notifications

### Potential Phase 5: Advanced Productivity (8-10 weeks)
- Template system for common workflows
- Time tracking and analytics
- Integrations (Google Calendar, Todoist import)
- Widgets for mobile home screen
- Dark mode enhancements
- Custom themes
- Data export/import (JSON, Markdown, CSV)

---

## Documentation Plan

### Developer Documentation
- [ ] README with setup instructions
- [ ] Architecture overview diagram
- [ ] Data model documentation
- [ ] API reference (repository methods)
- [ ] Contributing guidelines
- [ ] Code style guide

### User Documentation
- [ ] Onboarding guide (in-app)
- [ ] Quick start tutorial
- [ ] FAQ section
- [ ] Troubleshooting guide
- [ ] Privacy policy
- [ ] Terms of service

### Operational Documentation
- [ ] Deployment runbook
- [ ] Monitoring and alerting setup
- [ ] Incident response plan
- [ ] Backup and recovery procedures
- [ ] Supabase quota monitoring

---

## Monitoring & Analytics

### Technical Metrics (Post-Launch)
- App crashes (target: <1% of sessions)
- API response times (target: <500ms p95)
- Sync success rate (target: >99%)
- Database query performance
- Supabase quota usage

### Product Metrics
- Daily/Monthly Active Users (DAU/MAU)
- Items created per user per week (target: 5+)
- Space creation rate
- Quick capture usage frequency
- Account creation rate (Phase 2)
- Sync adoption rate (Phase 2)

### User Behavior Tracking (Privacy-Focused)
- Feature usage (which features are used most)
- User flows (where users drop off)
- Time to first meaningful action
- Retention cohorts (Day 1, 7, 30)
- Churn analysis

**Privacy Note**: All analytics anonymous, opt-in for detailed tracking, GDPR compliant

---

## Decision Log

### Key Architectural Decisions

**Decision 1: Hive over SQLite (Phase 1)**
- **Rationale**: Hive is pure Dart, faster, simpler for MVP
- **Trade-off**: Less mature than SQLite, no SQL queries
- **Alternative Considered**: drift (SQLite), rejected for complexity

**Decision 2: Provider over Riverpod**
- **Rationale**: Simpler, official recommendation, lower learning curve
- **Trade-off**: Less powerful than Riverpod
- **Alternative Considered**: Riverpod, rejected for MVP simplicity

**Decision 3: Last-Write-Wins Conflict Resolution**
- **Rationale**: Simplest strategy, works for MVP single-user scenario
- **Trade-off**: Potential data loss in concurrent edits
- **Alternative Considered**: CRDT, rejected for complexity; can add later

**Decision 4: Supabase over Firebase**
- **Rationale**: PostgreSQL (relational), better CLI, open source, code-first approach
- **Trade-off**: Smaller ecosystem than Firebase
- **Alternative Considered**: Firebase, rejected for lock-in concerns

**Decision 5: Soft Deletes (is_deleted flag)**
- **Rationale**: Enables sync of deletions, allows undo, audit trail
- **Trade-off**: Database never shrinks (needs cleanup job)
- **Alternative Considered**: Hard deletes, rejected for sync complexity

---

## Success Definition

The Later MVP is **successful** if, by end of Phase 2:

1. **Users can accomplish their goal**: Create, organize, and manage tasks/notes/lists effortlessly
2. **Offline-first works**: 40%+ of sessions occur offline without issues
3. **Sync is reliable**: <1% of users experience sync problems
4. **Users trust the app**: 4+ star rating, positive feedback on data safety
5. **Foundation is solid**: Codebase is maintainable, extensible, well-tested
6. **Runway is clear**: Clear path to Phase 3 features and monetization

The MVP is **ready for public launch** if:
- All P0 and P1 features are stable
- No critical bugs remain
- Performance targets consistently met
- Accessibility standards achieved
- Beta testers report high satisfaction
- Backend infrastructure scales to 1000+ users

---

## Next Steps

### Immediate Actions (Before Starting Phase 1)
1. **Review all plan documents thoroughly**
2. **Set up development environment** (Flutter SDK, IDE, Git)
3. **Clone or create project repository**
4. **Create project board** (GitHub Projects, Trello, etc.) with tasks from Phase 1.1
5. **Establish communication** (where to ask questions, report progress)
6. **Schedule kickoff meeting** (if working with team/stakeholders)

### Phase 1 Kickoff Checklist
- [ ] Development environment verified (flutter doctor passes)
- [ ] Project repository initialized with README
- [ ] Design documentation accessible and understood
- [ ] First sprint planned (1-2 weeks of tasks)
- [ ] Success criteria for Phase 1 agreed upon
- [ ] Decision: Target platforms for initial release (iOS, Android, Web, Desktop)

### Communication Cadence
- **Daily**: Update task board with progress
- **Weekly**: Review completed work, plan next week
- **Bi-weekly**: Demo progress to stakeholders (if applicable)
- **Phase End**: Retrospective and planning for next phase

---

## Appendix: Quick Reference

### File Structure
```
later/
├── .claude/
│   ├── plans/
│   │   ├── mvp-master-plan.md          ← You are here
│   │   ├── mvp-phase-1-foundation.md   ← Phase 1 details
│   │   └── mvp-phase-2-supabase-sync.md ← Phase 2 details
│   ├── docs/
│   │   ├── DEVELOPER_QUICKSTART.md
│   │   ├── DESIGN_SYSTEM_SUMMARY.md
│   │   ├── project-documentation/
│   │   └── design-documentation/
│   └── research/
│       └── supabase-cli-free-tier-capabilities.md
├── lib/
│   ├── core/
│   ├── data/
│   ├── providers/
│   └── widgets/
├── supabase/                           ← Phase 2
│   ├── migrations/
│   ├── config.toml
│   └── seed.sql
├── pubspec.yaml
└── README.md
```

### Command Cheat Sheet

**Flutter**
```bash
flutter create later
flutter pub get
flutter run
flutter test
flutter analyze
flutter build apk
flutter build ios
```

**Supabase (Phase 2)**
```bash
supabase init
supabase start
supabase stop
supabase db reset
supabase migration new [name]
supabase db push
supabase gen types typescript --local
```

### Key Contacts (Update as needed)
- **Project Lead**: [Name]
- **Designer**: [Name]
- **QA Tester**: [Name]
- **Stakeholder**: [Name]

---

**Document Version**: 1.0
**Last Updated**: 2025-10-18
**Status**: Ready for Implementation
**Next Review**: After Phase 1 Completion
