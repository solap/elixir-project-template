# Review Plan

Review and improve an existing plan for completeness and quality.

## Instructions

Given the plan file path: $ARGUMENTS

1. **Read the Plan**
   - Read the entire plan file
   - Understand the goal and approach
   - Note the structure and level of detail

2. **Analyze for Completeness**
   - Are all required sections present?
   - Is the problem/feature clearly defined?
   - Are implementation steps specific and actionable?
   - Is there a testing strategy?
   - Are validation commands included?
   - Is there a rollback strategy?

3. **Check for Quality**
   - Are steps in logical order?
   - Are dependencies between steps clear?
   - Are acceptance criteria measurable?
   - Is technical detail sufficient?
   - Are edge cases considered?

4. **Security Review**
   - Are there any security implications?
   - Is input validation considered?
   - Are authentication/authorization addressed?
   - Are secrets/credentials handled safely?
   - Is SQL injection prevented?
   - Is XSS prevention considered?

5. **Performance Considerations**
   - Are there potential performance bottlenecks?
   - Is database query optimization needed?
   - Are there N+1 query risks?
   - Is caching strategy appropriate?

6. **Suggest Improvements**
   - List specific improvements needed
   - Provide examples of better wording/steps
   - Suggest additional tests or validation
   - Recommend security hardening
   - Propose performance optimizations

7. **Provide Rating**
   - Rate the plan: Excellent / Good / Needs Work / Insufficient
   - Justify the rating with specific examples
   - Prioritize critical issues vs nice-to-haves

## Output Format

Provide review as:

```markdown
# Plan Review: [Plan Name]

## Overall Rating
[Excellent/Good/Needs Work/Insufficient]

## Strengths
- [List what's done well]

## Critical Issues
- [Must be addressed before implementation]

## Suggestions for Improvement
- [Nice-to-haves and enhancements]

## Security Concerns
- [Any security implications]

## Performance Considerations
- [Performance impacts to consider]

## Recommended Next Steps
- [What should be done before implementing]
```
