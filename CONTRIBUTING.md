# Contributing to Puchi

Thank you for your interest in contributing to Puchi! This document provides guidelines and information for contributors.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Code Standards](#code-standards)
- [Testing Guidelines](#testing-guidelines)
- [Documentation](#documentation)
- [Submitting Changes](#submitting-changes)
- [Issue Guidelines](#issue-guidelines)
- [Community Guidelines](#community-guidelines)

## Code of Conduct

This project adheres to a code of conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to conduct@puchi.io.vn.

### Our Standards

**Positive behavior:**

- Using welcoming and inclusive language
- Being respectful of differing viewpoints and experiences
- Gracefully accepting constructive criticism
- Focusing on what is best for the community
- Showing empathy towards other community members

**Unacceptable behavior:**

- The use of sexualized language or imagery
- Trolling, insulting/derogatory comments, and personal or political attacks
- Public or private harassment
- Publishing others' private information without permission
- Other conduct which could reasonably be considered inappropriate

## Getting Started

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/) 20.10+
- [Kubernetes](https://kubernetes.io/docs/tasks/tools/) 1.25+
- [Node.js](https://nodejs.org/) 18+
- [Go](https://golang.org/dl/) 1.21+
- [Git](https://git-scm.com/downloads) 2.30+

### Setting Up Development Environment

1. **Fork and Clone**

   ```bash
   git clone https://github.com/your-username/puchi-app.git
   cd puchi-app
   ```

2. **Initialize Project**

   ```bash
   make init
   ```

3. **Start Development Environment**

   ```bash
   make dev-start
   ```

4. **Verify Setup**
   - Frontend: http://localhost:3000
   - API Gateway: http://localhost:9080
   - Auth Service: http://localhost:3567

## Development Workflow

### Branch Naming Convention

Use descriptive branch names with prefixes:

- `feature/` - New features
- `bugfix/` - Bug fixes
- `hotfix/` - Critical bug fixes
- `refactor/` - Code refactoring
- `docs/` - Documentation updates
- `test/` - Test improvements
- `chore/` - Maintenance tasks

Examples:

- `feature/user-authentication`
- `bugfix/login-validation-error`
- `docs/api-documentation-update`

### Commit Message Convention

Follow [Conventional Commits](https://conventionalcommits.org/):

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Types:**

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks
- `perf`: Performance improvements
- `ci`: CI/CD changes
- `build`: Build system changes
- `revert`: Revert previous commit

**Examples:**

```
feat(auth): add social login support

fix(user-service): resolve profile update validation

docs: update API documentation

chore: update dependencies
```

### Pull Request Process

1. **Create Feature Branch**

   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make Changes**

   - Write code following our standards
   - Add tests for new functionality
   - Update documentation as needed

3. **Test Your Changes**

   ```bash
   make test
   make lint
   make security-scan
   ```

4. **Commit Changes**

   ```bash
   git add .
   git commit -m "feat: add your feature description"
   ```

5. **Push and Create PR**

   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create Pull Request**
   - Use the PR template
   - Provide clear description
   - Link related issues
   - Request appropriate reviewers

## Code Standards

### Frontend (Next.js/TypeScript)

#### Code Style

- Use TypeScript for all new code
- Follow ESLint and Prettier configurations
- Use meaningful variable and function names
- Write self-documenting code

#### Component Guidelines

```typescript
// ✅ Good
interface UserProfileProps {
  userId: string;
  showAvatar?: boolean;
}

export const UserProfile: React.FC<UserProfileProps> = ({
  userId,
  showAvatar = true,
}) => {
  // Component implementation
};

// ❌ Bad
export const UserProfile = ({ userId, showAvatar }) => {
  // Component implementation
};
```

#### File Organization

```
src/
├── components/          # Reusable components
│   ├── ui/             # Basic UI components
│   └── features/       # Feature-specific components
├── pages/              # Next.js pages
├── hooks/              # Custom React hooks
├── services/           # API service functions
├── types/              # TypeScript type definitions
├── utils/              # Utility functions
└── styles/             # Global styles
```

### Backend (Go)

#### Code Style

- Follow Go conventions and best practices
- Use `gofmt` and `golint`
- Write comprehensive tests
- Document public APIs

#### Project Structure

```
cmd/                    # Application entry points
├── app/
│   └── main.go        # Main application
internal/               # Private application code
├── handler/           # HTTP handlers
├── service/           # Business logic
├── repository/        # Data access layer
└── model/             # Data models
pkg/                    # Public packages
migrations/             # Database migrations
```

#### Example Code

```go
// ✅ Good
type UserService struct {
    repo UserRepository
}

func NewUserService(repo UserRepository) *UserService {
    return &UserService{
        repo: repo,
    }
}

func (s *UserService) GetUser(ctx context.Context, id string) (*User, error) {
    if id == "" {
        return nil, errors.New("user ID cannot be empty")
    }

    return s.repo.FindByID(ctx, id)
}

// ❌ Bad
func GetUser(id string) *User {
    return repo.FindByID(id)
}
```

### General Guidelines

#### Error Handling

- Always handle errors explicitly
- Provide meaningful error messages
- Log errors appropriately
- Use proper HTTP status codes

#### Performance

- Optimize database queries
- Use caching where appropriate
- Minimize bundle sizes
- Implement proper pagination

#### Security

- Validate all inputs
- Use parameterized queries
- Implement proper authentication
- Follow OWASP guidelines

## Testing Guidelines

### Frontend Testing

#### Unit Tests

```typescript
import { render, screen } from "@testing-library/react";
import { UserProfile } from "./UserProfile";

describe("UserProfile", () => {
  it("renders user information correctly", () => {
    render(<UserProfile userId="123" />);

    expect(screen.getByText("John Doe")).toBeInTheDocument();
    expect(screen.getByAltText("User avatar")).toBeInTheDocument();
  });
});
```

#### Integration Tests

```typescript
import { render, screen, waitFor } from "@testing-library/react";
import { UserProfile } from "./UserProfile";

describe("UserProfile Integration", () => {
  it("loads and displays user data", async () => {
    render(<UserProfile userId="123" />);

    await waitFor(() => {
      expect(screen.getByText("Loading...")).not.toBeInTheDocument();
    });

    expect(screen.getByText("John Doe")).toBeInTheDocument();
  });
});
```

### Backend Testing

#### Unit Tests

```go
func TestUserService_GetUser(t *testing.T) {
    repo := &MockUserRepository{}
    service := NewUserService(repo)

    expectedUser := &User{ID: "123", Name: "John Doe"}
    repo.On("FindByID", "123").Return(expectedUser, nil)

    user, err := service.GetUser(context.Background(), "123")

    assert.NoError(t, err)
    assert.Equal(t, expectedUser, user)
    repo.AssertExpectations(t)
}
```

#### Integration Tests

```go
func TestUserAPI_GetUser(t *testing.T) {
    // Setup test database
    db := setupTestDB(t)
    defer cleanupTestDB(t, db)

    // Create test user
    user := createTestUser(t, db, "John Doe")

    // Make API request
    req := httptest.NewRequest("GET", "/api/users/"+user.ID, nil)
    w := httptest.NewRecorder()

    handler.ServeHTTP(w, req)

    assert.Equal(t, http.StatusOK, w.Code)

    var response User
    json.Unmarshal(w.Body.Bytes(), &response)
    assert.Equal(t, user.Name, response.Name)
}
```

### Test Coverage Requirements

- **Minimum Coverage**: 80%
- **Critical Paths**: 95%
- **New Features**: 100% coverage required
- **Bug Fixes**: Tests must reproduce and fix the bug

## Documentation

### Code Documentation

#### Frontend

```typescript
/**
 * User profile component that displays user information and avatar
 *
 * @param userId - Unique identifier for the user
 * @param showAvatar - Whether to display the user's avatar (default: true)
 * @returns JSX element containing user profile information
 */
export const UserProfile: React.FC<UserProfileProps> = ({
  userId,
  showAvatar = true,
}) => {
  // Implementation
};
```

#### Backend

```go
// UserService handles user-related business logic
type UserService struct {
    repo UserRepository
}

// GetUser retrieves a user by their ID
// Returns an error if the user is not found or if the ID is invalid
func (s *UserService) GetUser(ctx context.Context, id string) (*User, error) {
    // Implementation
}
```

### API Documentation

- Use OpenAPI/Swagger for API documentation
- Provide examples for all endpoints
- Document error responses
- Include authentication requirements

### README Updates

- Update README.md for significant changes
- Include setup instructions for new features
- Document configuration changes
- Provide troubleshooting information

## Submitting Changes

### Pull Request Template

```markdown
## Description

Brief description of changes

## Type of Change

- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing

- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Checklist

- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No breaking changes (or breaking changes documented)
```

### Review Process

1. **Automated Checks**

   - CI/CD pipeline runs tests
   - Code quality checks
   - Security scans
   - Coverage reports

2. **Manual Review**

   - Code review by team members
   - Architecture review for significant changes
   - Security review for sensitive changes

3. **Approval**
   - At least one approval required
   - All checks must pass
   - No merge conflicts

### Merge Process

- Use "Squash and merge" for feature branches
- Use "Merge commit" for release branches
- Delete feature branches after merge
- Update version numbers for releases

## Issue Guidelines

### Bug Reports

```markdown
**Describe the bug**
A clear description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:

1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
What you expected to happen.

**Screenshots**
If applicable, add screenshots.

**Environment:**

- OS: [e.g. macOS, Windows, Linux]
- Browser: [e.g. Chrome, Safari]
- Version: [e.g. 1.0.0]

**Additional context**
Any other context about the problem.
```

### Feature Requests

```markdown
**Is your feature request related to a problem?**
A clear description of what the problem is.

**Describe the solution you'd like**
A clear description of what you want to happen.

**Describe alternatives you've considered**
Alternative solutions or features you've considered.

**Additional context**
Any other context or screenshots about the feature request.
```

## Community Guidelines

### Getting Help

1. **Check Documentation**: Look in the `docs/` directory
2. **Search Issues**: Check existing GitHub issues
3. **Ask Questions**: Use GitHub Discussions
4. **Join Community**: Join our Discord server

### Reporting Issues

- Use appropriate issue templates
- Provide sufficient detail
- Include reproduction steps
- Be respectful and constructive

### Contributing Back

- Fix bugs you encounter
- Improve documentation
- Add tests for better coverage
- Share your use cases and feedback

## Recognition

Contributors will be recognized in:

- CONTRIBUTORS.md file
- Release notes
- Project documentation
- Community announcements

## Questions?

If you have questions about contributing:

- **Email**: contribute@puchi.io.vn
- **Discord**: [Join our community](https://discord.gg/puchi)
- **GitHub Discussions**: [Ask questions](https://github.com/hoan02/puchi-app/discussions)

Thank you for contributing to Puchi! 🚀
