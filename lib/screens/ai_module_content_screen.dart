import 'package:flutter/material.dart';
import '../services/groq_service.dart';
import '../services/activity_service.dart';
import '../services/youtube_service.dart';
import '../widgets/youtube_video_widget.dart';
import 'course_completion_quiz_screen.dart';
import 'youtube_search_screen.dart';

class AIModuleContentScreen extends StatefulWidget {
  final String moduleTitle;
  final String moduleDescription;
  final String? learningStyle;
  final String? courseTitle;

  const AIModuleContentScreen({
    super.key,
    required this.moduleTitle,
    required this.moduleDescription,
    this.learningStyle,
    this.courseTitle,
  });

  @override
  State<AIModuleContentScreen> createState() => _AIModuleContentScreenState();
}

class _AIModuleContentScreenState extends State<AIModuleContentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GroqService _groqService = GroqService();

  // Cache for AI-generated content
  final Map<String, Future<String>> _contentCache = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _trackModuleStart();
  }

  void _trackModuleStart() async {
    // Add activity for starting a module
    await ActivityService.addActivity(
      type: ActivityService.activityModule,
      title: 'Started ${widget.moduleTitle}',
      description: 'Began learning module content',
      metadata: {
        'moduleTitle': widget.moduleTitle,
        'courseTitle': widget.courseTitle,
        'learningStyle': widget.learningStyle,
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<String> _generateContent(String promptType) async {
    String prompt = '';

    switch (promptType) {
      case 'content':
        prompt =
            '''Create comprehensive and detailed educational content for "${widget.moduleTitle}" with extensive explanations and minimal sub-headings:

${widget.moduleDescription}

Structure the content with only 4 main sections, but make each section extremely detailed and comprehensive:

# ${widget.moduleTitle}

## 1. Introduction and Fundamental Concepts
Write an extensive introduction (5-8 detailed paragraphs) that covers:
- Complete definition and explanation of the topic
- Historical background and evolution
- Why this topic is important and relevant today
- Core terminology and key concepts explained in depth
- Real-world significance and applications
- How this topic relates to other fields and technologies
- Current trends and future directions
- Foundational principles that govern this field

Make this section comprehensive with detailed explanations rather than bullet points. Each concept should be thoroughly explained with examples and context.

## 2. Detailed Mechanisms and Processes
Provide an in-depth exploration (4-6 paragraphs) covering:
- How everything works at a detailed technical level
- Step-by-step processes and methodologies
- Technical principles and underlying mechanisms
- Different approaches and methodologies available
- Comparative analysis of various techniques
- Technical requirements and prerequisites
- Integration with existing systems and technologies
- Performance considerations and optimization strategies

Focus on thorough explanations with detailed descriptions rather than lists. Explain the reasoning behind each approach.

## 3. Comprehensive Applications and Examples
Create an extensive section (4-5 paragraphs) that includes:
- Multiple detailed real-world applications across industries
- Comprehensive case studies with full explanations
- Practical implementation scenarios with complete context
- Industry-specific use cases with detailed backgrounds
- Success stories and lessons learned from implementations
- Code examples or technical implementations where relevant
- Problem-solving approaches and troubleshooting methods
- Integration examples with other technologies and systems

Provide complete context and detailed explanations for each application rather than simple lists.

## 4. Professional Implementation and Best Practices
Deliver a thorough guide (4-5 paragraphs) covering:
- Professional standards and industry best practices
- Complete implementation strategies and methodologies
- Common challenges and detailed solution approaches
- Performance optimization techniques and considerations
- Security considerations and compliance requirements
- Testing and validation approaches
- Maintenance and long-term sustainability strategies
- Career applications and professional development opportunities

Focus on actionable insights with detailed explanations and practical guidance.

IMPORTANT FORMATTING GUIDELINES:
- Write in detailed paragraphs with comprehensive explanations
- Avoid excessive bullet points or sub-headings within sections
- Use **bold** for key terms and important concepts
- Use *italic* for emphasis and technical terms
- Use `code` formatting for technical terms, functions, and commands
- Include real examples and detailed case studies
- Make each section substantial with thorough coverage
- Aim for educational depth rather than surface-level information
- Provide context and reasoning for all concepts presented

Use extensive markdown formatting:
- **Bold** for all key terms and important concepts
- *Italic* for emphasis and definitions
- `code` for technical terms, functions, and commands
- ### for all subsections within main sections
- #### for sub-subsections if needed
- - for bullet points
- 1. for numbered lists and processes
- > for important quotes or notes
- ```code blocks``` for examples

Make the content comprehensive, educational, and well-structured. Aim for detailed explanations that thoroughly cover the topic.''';
        break;
      case 'simplified':
        prompt =
            '''Create a comprehensive yet beginner-friendly explanation of "${widget.moduleTitle}" without emojis and with substantial content in each section:

# ${widget.moduleTitle} - Beginner's Guide

## What is ${widget.moduleTitle}?
Write 2-3 detailed paragraphs that provide a complete yet simple explanation covering:
- A clear definition using everyday language and analogies
- Why this topic exists and what problems it solves
- How it fits into the bigger picture of the field
- Real-world examples that anyone can understand

## Essential Concepts to Understand
Create a comprehensive explanation (2-3 paragraphs) covering:
- The fundamental principles explained in simple terms
- Key terminology defined with examples and context
- How different parts work together as a system
- Common misconceptions clarified with accurate information
- The most important ideas that beginners must grasp

## Learning Path and Getting Started
Provide detailed guidance (2-3 paragraphs) including:
- Step-by-step approach to learning this topic effectively
- Prerequisites and background knowledge needed
- Recommended sequence of study and practice
- Resources and tools that are most helpful for beginners
- How to practice and apply what you learn

## Practical Applications and Career Value
Write a substantial section (2-3 paragraphs) explaining:
- Real industries and jobs where this knowledge is valuable
- Specific ways professionals use these concepts daily
- Career opportunities and salary potential
- How mastering this topic opens doors to other areas
- Success stories and practical benefits of learning this skill

FORMATTING GUIDELINES:
- Write in clear, detailed paragraphs rather than bullet points
- Use **bold** for important terms and key concepts
- Use *italic* for emphasis and technical terms when needed
- Use simple, encouraging language that builds confidence
- Include specific examples and real-world connections
- Make each section substantial with thorough explanations
- Avoid emojis and visual indicators in the content''';
        break;
      case 'quiz':
        prompt =
            'Generate 5 multiple-choice questions with answers for "${widget.moduleTitle}". Format as Q1: question, A) option B) option C) option D) option, Answer: correct option.';
        break;
      case 'examples':
        prompt =
            'Provide 3 practical examples and code snippets (if applicable) for "${widget.moduleTitle}" with detailed explanations.';
        break;
      case 'videos':
        prompt =
            'Suggest 5 YouTube search terms and video topics that would help someone learn "${widget.moduleTitle}".';
        break;
    }

    // Add learning style specific instructions
    if (widget.learningStyle != null) {
      switch (widget.learningStyle) {
        case 'Visual':
          prompt +=
              ' Focus on visual descriptions, suggest diagrams, and use formatting that helps visual learners.';
          break;
        case 'Auditory':
          prompt +=
              ' Structure the explanation for reading aloud and include discussion points.';
          break;
        case 'Reading/Writing':
          prompt +=
              ' Provide detailed written explanations with clear structure and key points.';
          break;
        case 'Kinesthetic':
          prompt +=
              ' Include practical examples and hands-on activities where possible.';
          break;
      }
    }

    try {
      print('🔵 Generating content for: $promptType');
      final response = await _groqService.generateTextContent(prompt);
      print('🔵 Response received successfully');
      return response;
    } catch (e) {
      print('🔴 Error generating content: $e');

      // Check if it's a rate limit error
      if (e.toString().contains('rate_limit_exceeded') ||
          e.toString().contains('429')) {
        return '''## ⏰ Rate Limit Reached
        
The AI service has reached its daily usage limit. Please try again in about 1 hour when the limit resets.

**What you can do:**
- Wait for the limit to reset (usually 1-2 hours)
- Use the offline content below as a reference
- Upgrade your API plan for higher limits

---

${_getFallbackContent(promptType)}''';
      }

      return _getFallbackContent(promptType);
    }
  }

  String _getWebDevelopmentContent(String promptType) {
    switch (promptType) {
      case 'content':
        return '''# HTML & CSS Foundations

## 📖 Course Overview
Welcome to the HTML and CSS Foundations module. This comprehensive course will teach you the fundamental building blocks of web development through hands-on learning and practical examples.

---

## 🎯 Learning Objectives
By the end of this module, you will be able to:
- Create well-structured HTML documents
- Apply CSS styling to enhance visual presentation
- Build responsive layouts that work on all devices
- Implement accessibility best practices
- Debug and optimize web pages for performance

---

## 1️⃣ HTML Fundamentals

### What is HTML?
HTML (HyperText Markup Language) is the standard markup language for creating web pages. It describes the structure and content of a webpage using elements and tags.

**Key Features:**
- Semantic structure for content organization
- Cross-platform compatibility
- Search engine optimization friendly
- Accessibility support built-in

### HTML Document Structure
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document Title</title>
</head>
<body>
    <header>
        <nav>Navigation</nav>
    </header>
    <main>
        <section>Content sections</section>
    </main>
    <footer>Footer content</footer>
</body>
</html>
```

### Essential HTML Elements
**Text Elements:**
- `<h1>` to `<h6>`: Headings (hierarchy matters)
- `<p>`: Paragraphs
- `<span>`: Inline text container
- `<div>`: Block-level container

**Semantic Elements:**
- `<header>`: Page or section header
- `<nav>`: Navigation links
- `<main>`: Main content area
- `<section>`: Thematic content grouping
- `<article>`: Independent content
- `<aside>`: Sidebar content
- `<footer>`: Page or section footer

**Interactive Elements:**
- `<a href="url">`: Links
- `<button>`: Clickable buttons
- `<form>`: User input forms
- `<input>`: Form input fields

---

## 2️⃣ CSS Fundamentals

### What is CSS?
CSS (Cascading Style Sheets) controls the visual presentation of HTML elements. It separates content from design, making websites easier to maintain and more flexible.

### CSS Syntax
```css
selector {
    property: value;
    property: value;
}
```

### CSS Selectors
**Basic Selectors:**
- Element: `h1 { }` - Targets all h1 elements
- Class: `.className { }` - Targets elements with specific class
- ID: `#idName { }` - Targets element with specific ID
- Universal: `* { }` - Targets all elements

**Combination Selectors:**
- Descendant: `.parent .child` - Child elements inside parent
- Direct child: `.parent > .child` - Direct children only
- Adjacent: `.element + .next` - Next sibling element

### The Box Model
Every HTML element is a rectangular box consisting of:
1. **Content**: The actual content (text, images)
2. **Padding**: Space between content and border
3. **Border**: Line around the padding and content
4. **Margin**: Space outside the border

```css
.box {
    width: 200px;
    height: 100px;
    padding: 20px;
    border: 2px solid black;
    margin: 10px;
}
```

---

## 3️⃣ Layout Techniques

### Flexbox Layout
Flexbox provides an efficient way to arrange elements in a one-dimensional layout.

```css
.flex-container {
    display: flex;
    justify-content: center;
    align-items: center;
    flex-direction: row;
}

.flex-item {
    flex: 1;
    margin: 10px;
}
```

### CSS Grid
Grid layout enables two-dimensional layouts with rows and columns.

```css
.grid-container {
    display: grid;
    grid-template-columns: 1fr 2fr 1fr;
    grid-template-rows: auto;
    gap: 20px;
}

.grid-item {
    grid-column: span 2;
}
```

### Responsive Design
Create layouts that adapt to different screen sizes using media queries.

```css
/* Mobile First Approach */
.container {
    width: 100%;
    padding: 10px;
}

/* Tablet */
@media (min-width: 768px) {
    .container {
        max-width: 750px;
        margin: 0 auto;
    }
}

/* Desktop */
@media (min-width: 1024px) {
    .container {
        max-width: 1200px;
        padding: 20px;
    }
}
```

---

## 4️⃣ Best Practices

### HTML Best Practices
✅ **Do:**
- Use semantic HTML elements
- Include proper DOCTYPE and meta tags
- Validate your HTML code
- Use meaningful alt attributes for images
- Structure content hierarchically with headings

❌ **Avoid:**
- Using deprecated elements
- Skipping heading levels
- Inline styles in HTML
- Missing closing tags
- Non-semantic div/span overuse

### CSS Best Practices
✅ **Do:**
- Use external stylesheets
- Follow consistent naming conventions
- Group related styles together
- Use CSS reset or normalize
- Optimize for performance

❌ **Avoid:**
- Overusing !important
- Inline styles
- Overly specific selectors
- Unused CSS code
- Hard-coded values everywhere

---

## 5️⃣ Modern CSS Features

### CSS Variables (Custom Properties)
```css
:root {
    --primary-color: #3498db;
    --font-size: 16px;
    --spacing: 1rem;
}

.button {
    background-color: var(--primary-color);
    font-size: var(--font-size);
    padding: var(--spacing);
}
```

### CSS Animations
```css
@keyframes slideIn {
    from {
        transform: translateX(-100%);
        opacity: 0;
    }
    to {
        transform: translateX(0);
        opacity: 1;
    }
}

.animated-element {
    animation: slideIn 0.5s ease-in-out;
}
```

### CSS Transforms
```css
.hover-effect {
    transition: transform 0.3s ease;
}

.hover-effect:hover {
    transform: scale(1.05) rotate(2deg);
}
```

---

## 🔧 Tools and Resources

### Development Tools
- **Code Editors**: VS Code, Sublime Text, Atom
- **Browser DevTools**: Chrome DevTools, Firefox Developer Tools
- **Online Editors**: CodePen, JSFiddle, CodeSandbox
- **Validators**: W3C HTML Validator, CSS Validator

### Learning Resources
- **Documentation**: MDN Web Docs, W3Schools
- **Practice Platforms**: freeCodeCamp, Codecademy
- **Design Inspiration**: Dribbble, Behance, Awwwards
- **CSS Games**: Flexbox Froggy, CSS Grid Garden

---

## 📊 Assessment Checklist

Before moving to the next module, ensure you can:
□ Create a basic HTML document structure
□ Apply CSS styles using different selectors
□ Implement responsive layouts with Flexbox/Grid
□ Use semantic HTML elements appropriately
□ Debug CSS issues using browser DevTools
□ Optimize code for performance and accessibility

---

## 🚀 Next Steps

After mastering HTML and CSS basics:
1. **JavaScript**: Add interactivity to your websites
2. **CSS Frameworks**: Bootstrap, Tailwind CSS
3. **Preprocessors**: Sass, Less
4. **Build Tools**: Webpack, Vite
5. **Version Control**: Git and GitHub

Remember: Practice is key to mastering web development. Start building projects and experimenting with different layouts and designs!

## 2. The Importance of HTML and CSS

### Foundational Significance
The importance of HTML and CSS cannot be overstated, as they are the foundation upon which all web pages are built. Without a solid understanding of these languages, it is impossible to create functional and visually appealing web pages. These technologies serve as the fundamental building blocks that enable the creation of everything from simple static websites to complex interactive web applications.

HTML provides the structural backbone that gives meaning and organization to web content, while CSS transforms raw content into polished, professional-looking interfaces. Together, they create the user-facing layer of the internet that billions of people interact with daily.

### Real-World Significance and Applications
The real-world significance of HTML and CSS is evident in the fact that they are used in virtually every web page on the internet. From simple brochure websites showcasing local businesses to complex web applications powering global enterprises, HTML and CSS are the languages used to create the user interface and user experience.

**Universal Web Presence:**
- **Corporate Websites**: Every major company relies on HTML and CSS for their online presence
- **E-commerce Platforms**: Online shopping experiences are built with these technologies
- **Social Media Networks**: User interfaces of platforms like Facebook, Twitter, and LinkedIn
- **Educational Platforms**: Online learning systems and university websites
- **Government Services**: Public service websites and digital government initiatives
- **Entertainment Industry**: Streaming services, gaming websites, and media platforms

**Professional Applications:**
- **Content Management Systems**: WordPress, Drupal, and Joomla all generate HTML and CSS
- **Email Marketing**: Newsletter templates and promotional emails
- **Mobile Applications**: Hybrid apps and progressive web applications
- **Digital Marketing**: Landing pages, advertisements, and promotional materials
- **Documentation Systems**: Technical documentation and user manuals
- **Business Applications**: Internal tools, dashboards, and reporting systems

### Industry Impact and Career Opportunities
Understanding HTML and CSS opens doors to numerous career paths in the rapidly growing technology sector. The global web development market continues to expand, creating consistent demand for professionals who can work with these technologies.

**Career Pathways:**
- **Front-End Developer**: Creating user interfaces and interactive experiences
- **Web Designer**: Focusing on visual design and user experience
- **UI/UX Designer**: Designing and implementing user-centered interfaces
- **Full-Stack Developer**: Working with both front-end and back-end technologies
- **Email Marketing Specialist**: Creating responsive email campaigns
- **Digital Marketing Professional**: Building landing pages and marketing materials
- **Content Management Specialist**: Managing and styling web content
- **Freelance Web Developer**: Independent project-based work

**Salary and Growth Potential:**
- Entry-level positions typically offer competitive starting salaries
- Experienced developers can command premium rates
- Freelance opportunities provide flexible income streams
- Continuous learning leads to career advancement and specialization opportunities

### Current Trends and Modern Development
The current trends in HTML and CSS are focused on creating responsive, accessible, and performant web pages, using techniques such as mobile-first design, progressive enhancement, and code optimization strategies.

**Responsive Web Design:**
- **Mobile-First Approach**: Designing for mobile devices before desktop
- **Flexible Grid Systems**: Creating layouts that adapt to any screen size
- **Responsive Images**: Optimizing images for different devices and resolutions
- **Touch-Friendly Interfaces**: Designing for touch interactions and gestures
- **Cross-Device Compatibility**: Ensuring consistent experiences across all devices

**Accessibility and Inclusion:**
- **WCAG Compliance**: Following Web Content Accessibility Guidelines
- **Screen Reader Compatibility**: Creating content accessible to visually impaired users
- **Keyboard Navigation**: Ensuring full functionality without a mouse
- **Color Contrast Standards**: Maintaining readability for users with visual impairments
- **Semantic HTML**: Using proper markup for assistive technologies

**Performance Optimization:**
- **Critical CSS**: Loading essential styles first for faster page rendering
- **CSS Modules**: Organizing stylesheets for better maintainability
- **Minification and Compression**: Reducing file sizes for faster loading
- **Progressive Enhancement**: Building baseline functionality then adding advanced features
- **Web Fonts Optimization**: Loading custom fonts efficiently

**Modern CSS Features:**
- **CSS Grid**: Advanced two-dimensional layout system
- **Flexbox**: Flexible one-dimensional layout method
- **CSS Variables**: Dynamic styling with custom properties
- **CSS Animations**: Creating smooth transitions and interactive effects
- **CSS Preprocessing**: Using tools like Sass and Less for enhanced functionality

### Economic and Business Impact
HTML and CSS proficiency directly translates to business value and economic opportunities in today's digital economy.

**Business Benefits:**
- **Cost-Effective Development**: Faster development cycles and reduced costs
- **Brand Recognition**: Consistent visual identity across digital platforms
- **Customer Engagement**: Better user experiences leading to increased conversions
- **Market Reach**: Ability to reach global audiences through web presence
- **Competitive Advantage**: Professional web presence differentiates businesses
- **Scalability**: Foundation for growing digital products and services

**Economic Significance:**
- **Digital Transformation**: Essential skills for business digitization
- **Remote Work Opportunities**: Skills applicable to distributed teams
- **Entrepreneurial Ventures**: Foundation for launching digital businesses
- **Consulting Opportunities**: Helping businesses improve their web presence
- **Continuous Learning Value**: Skills that appreciate with experience and specialization

### Future-Proofing and Technology Evolution
Learning HTML and CSS provides a solid foundation for adapting to future web technologies and trends.

**Emerging Technologies:**
- **Progressive Web Apps**: Combining web and mobile app capabilities
- **WebAssembly Integration**: Enhancing web performance with compiled languages
- **Voice Interfaces**: Designing for voice-activated browsing
- **Augmented Reality**: Web-based AR experiences
- **Internet of Things**: Web interfaces for connected devices
- **Artificial Intelligence**: AI-enhanced web development tools

**Skill Transferability:**
- **Framework Adaptability**: Understanding core concepts makes learning React, Vue, and Angular easier
- **Design Systems**: Knowledge applicable to building scalable design systems
- **Cross-Platform Development**: Skills useful for mobile and desktop application development
- **Content Strategy**: Understanding structure and presentation for content creation
- **Digital Product Development**: Foundation for creating digital products and services

This comprehensive understanding of HTML and CSS importance demonstrates why these technologies remain central to web development and continue to offer valuable career and business opportunities in our increasingly digital world.

## 3. Core Principles and Fundamentals

### HTML Structure and Semantics

#### Document Structure
Every HTML document follows a **standard structure**:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <!-- Metadata and resources -->
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Page Title</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <!-- Visible content -->
    <header>Navigation and branding</header>
    <main>Primary content</main>
    <footer>Additional information</footer>
</body>
</html>
```

#### Semantic Elements
**Semantic HTML** uses elements that *describe their content*:
- `<header>`: Site or section header
- `<nav>`: Navigation links
- `<main>`: Primary content area
- `<article>`: Independent, reusable content
- `<section>`: Thematic grouping of content
- `<aside>`: Sidebar or supplementary content
- `<footer>`: Site or section footer

### CSS Principles

#### The Cascade
CSS follows a **cascading system** with three key principles:

1. **Inheritance**: Child elements inherit certain properties from parents
2. **Specificity**: More specific selectors override less specific ones
3. **Source Order**: Later rules override earlier ones (when specificity is equal)

#### Specificity Hierarchy
1. **Inline styles**: `style="color: red;"` (Highest)
2. **IDs**: `#header { color: blue; }`
3. **Classes**: `.highlight { color: green; }`
4. **Elements**: `p { color: black; }` (Lowest)

## 3. Types and Classifications

### HTML Element Categories

#### Content Sectioning
- `<header>`, `<nav>`, `<main>`, `<section>`, `<article>`, `<aside>`, `<footer>`
- **Purpose**: Organize page structure semantically
- **Best Practice**: Use for document outline and accessibility

#### Text Content
- `<h1>` through `<h6>`: Headings (hierarchy matters)
- `<p>`: Paragraphs
- `<ul>`, `<ol>`, `<li>`: Lists
- `<blockquote>`: Extended quotations

#### Inline Text Elements
- `<strong>`: Important text (semantic emphasis)
- `<em>`: Emphasized text (semantic stress)
- `<code>`: Inline code
- `<a>`: Links and anchors

#### Form Elements
- `<form>`: Form container
- `<input>`: Various input types (text, email, password, etc.)
- `<textarea>`: Multi-line text input
- `<select>`, `<option>`: Dropdown selections
- `<button>`: Clickable buttons

### CSS Selector Types

#### Basic Selectors
- **Element**: `h1 { }` - Selects all h1 elements
- **Class**: `.highlight { }` - Selects elements with class="highlight"
- **ID**: `#header { }` - Selects element with id="header"
- **Universal**: `* { }` - Selects all elements

#### Advanced Selectors
- **Descendant**: `nav a { }` - Links inside nav elements
- **Child**: `nav > a { }` - Direct child links of nav
- **Pseudo-classes**: `:hover`, `:focus`, `:nth-child()`
- **Pseudo-elements**: `::before`, `::after`, `::first-line`

## 4. How It Works - Deep Dive

### HTML Rendering Process

#### Browser Parsing Steps
1. **HTML Parsing**: Browser reads HTML and creates DOM tree
2. **CSS Parsing**: Browser processes CSS and creates CSSOM
3. **Render Tree**: Combines DOM and CSSOM
4. **Layout**: Calculates element positions and sizes
5. **Paint**: Renders pixels to screen

#### DOM (Document Object Model)
The DOM represents the HTML document as a **tree structure**:
- Each HTML element becomes a *node*
- Nested elements become *child nodes*
- JavaScript can manipulate the DOM dynamically

### CSS Box Model Deep Dive

Every HTML element is rendered as a **rectangular box** with four areas:

```
┌─────────────────────────────────────────┐
│                Margin                   │
│  ┌───────────────────────────────────┐  │
│  │            Border                 │  │
│  │  ┌─────────────────────────────┐  │  │
│  │  │         Padding             │  │  │
│  │  │  ┌───────────────────────┐  │  │  │
│  │  │  │      Content          │  │  │  │
│  │  │  └───────────────────────┘  │  │  │
│  │  └─────────────────────────────┘  │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

#### Box Model Properties
- **Content**: The actual content (text, images)
- **Padding**: Space between content and border
- **Border**: Line around the padding
- **Margin**: Space outside the border

### CSS Layout Systems

#### Normal Flow
- **Block elements**: Take full width, stack vertically
- **Inline elements**: Flow horizontally, wrap at container edge
- **Inline-block**: Hybrid behavior

#### Flexbox Layout
**Modern layout system** for one-dimensional arrangements:

```css
.container {
    display: flex;
    justify-content: space-between; /* Horizontal alignment */
    align-items: center; /* Vertical alignment */
    gap: 20px; /* Space between items */
}
```

#### Grid Layout
**Two-dimensional layout system** for complex designs:

```css
.grid-container {
    display: grid;
    grid-template-columns: 1fr 2fr 1fr;
    grid-template-rows: auto 1fr auto;
    gap: 20px;
}
```

## 3. Practical Examples and Applications

### Basic HTML Structure
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My First Web Page</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <h1>Welcome to My Website</h1>
    <p>This is a paragraph with some text.</p>
</body>
</html>
```

### CSS Styling Example
```css
h1 {
    color: #333;
    font-family: Arial, sans-serif;
    text-align: center;
}

p {
    font-size: 16px;
    line-height: 1.6;
    margin: 20px 0;
}
```

## 5. Practical Examples and Applications

### Basic HTML Document Structure

#### Complete HTML Page Example
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Learn HTML and CSS fundamentals">
    <title>HTML & CSS Tutorial</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <header class="site-header">
        <nav class="navigation">
            <ul class="nav-list">
                <li><a href="#home">Home</a></li>
                <li><a href="#about">About</a></li>
                <li><a href="#contact">Contact</a></li>
            </ul>
        </nav>
    </header>
    
    <main class="main-content">
        <section class="hero">
            <h1 class="hero-title">Welcome to Web Development</h1>
            <p class="hero-description">Learn HTML and CSS from scratch</p>
            <button class="cta-button">Get Started</button>
        </section>
        
        <section class="features">
            <article class="feature-card">
                <h2>Semantic HTML</h2>
                <p>Build meaningful, accessible web structures</p>
            </article>
            <article class="feature-card">
                <h2>Modern CSS</h2>
                <p>Create beautiful, responsive designs</p>
            </article>
        </section>
    </main>
    
    <footer class="site-footer">
        <p>&copy; 2024 Web Development Tutorial</p>
    </footer>
</body>
</html>
```

#### Corresponding CSS Styling
```css
/* Reset and base styles */
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    line-height: 1.6;
    color: #333;
    background-color: #f4f4f4;
}

/* Header and Navigation */
.site-header {
    background-color: #2c3e50;
    padding: 1rem 0;
    box-shadow: 0 2px 5px rgba(0,0,0,0.1);
}

.navigation {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 2rem;
}

.nav-list {
    list-style: none;
    display: flex;
    gap: 2rem;
}

.nav-list a {
    color: white;
    text-decoration: none;
    font-weight: 500;
    transition: color 0.3s ease;
}

.nav-list a:hover {
    color: #3498db;
}

/* Main Content */
.main-content {
    max-width: 1200px;
    margin: 2rem auto;
    padding: 0 2rem;
}

.hero {
    text-align: center;
    padding: 4rem 0;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    border-radius: 10px;
    margin-bottom: 3rem;
}

.hero-title {
    font-size: 3rem;
    margin-bottom: 1rem;
    text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
}

.hero-description {
    font-size: 1.2rem;
    margin-bottom: 2rem;
    opacity: 0.9;
}

.cta-button {
    background-color: #e74c3c;
    color: white;
    padding: 1rem 2rem;
    border: none;
    border-radius: 5px;
    font-size: 1.1rem;
    cursor: pointer;
    transition: background-color 0.3s ease;
}

.cta-button:hover {
    background-color: #c0392b;
}

/* Features Section */
.features {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 2rem;
    margin: 3rem 0;
}

.feature-card {
    background: white;
    padding: 2rem;
    border-radius: 8px;
    box-shadow: 0 4px 6px rgba(0,0,0,0.1);
    transition: transform 0.3s ease;
}

.feature-card:hover {
    transform: translateY(-5px);
}

.feature-card h2 {
    color: #2c3e50;
    margin-bottom: 1rem;
    border-bottom: 2px solid #3498db;
    padding-bottom: 0.5rem;
}

/* Responsive Design */
@media (max-width: 768px) {
    .hero-title {
        font-size: 2rem;
    }
    
    .nav-list {
        flex-direction: column;
        gap: 1rem;
    }
    
    .features {
        grid-template-columns: 1fr;
    }
}

/* Footer */
.site-footer {
    background-color: #34495e;
    color: white;
    text-align: center;
    padding: 2rem 0;
    margin-top: 3rem;
}
```

### Form Example with Validation Styling
```html
<form class="contact-form" action="#" method="POST">
    <div class="form-group">
        <label for="name">Full Name:</label>
        <input type="text" id="name" name="name" required>
        <span class="error-message">Please enter your name</span>
    </div>
    
    <div class="form-group">
        <label for="email">Email:</label>
        <input type="email" id="email" name="email" required>
        <span class="error-message">Please enter a valid email</span>
    </div>
    
    <div class="form-group">
        <label for="message">Message:</label>
        <textarea id="message" name="message" rows="5" required></textarea>
    </div>
    
    <button type="submit" class="submit-button">Send Message</button>
</form>
```

### Real-World Applications

#### E-commerce Website Structure
- **Product listings**: Using CSS Grid for responsive layouts
- **Shopping cart**: Form elements with JavaScript interaction
- **User authentication**: Semantic forms with proper validation
- **Responsive design**: Mobile-first approach with media queries

#### Blog Platform
- **Article layout**: Semantic HTML5 elements (`<article>`, `<section>`)
- **Typography**: CSS for readable text and visual hierarchy  
- **Navigation**: Accessible menu systems with proper ARIA labels
- **Comments section**: Form handling and dynamic content

#### Corporate Website
- **Landing pages**: Hero sections with call-to-action buttons
- **About pages**: Team member cards with CSS animations
- **Contact forms**: Validation states and user feedback
- **Performance**: Optimized CSS and semantic HTML for SEO

## 6. Best Practices and Guidelines

### HTML Best Practices

#### Semantic Structure
```html
<!-- ✅ Good: Semantic and meaningful -->
<article class="blog-post">
    <header>
        <h1>Article Title</h1>
        <time datetime="2024-01-15">January 15, 2024</time>
    </header>
    <section class="content">
        <p>Article content here...</p>
    </section>
</article>

<!-- ❌ Bad: Non-semantic divs -->
<div class="blog-post">
    <div class="title">Article Title</div>
    <div class="date">January 15, 2024</div>
    <div class="content">Article content here...</div>
</div>
```

#### Accessibility Guidelines
- **Alt text** for images: `<img src="photo.jpg" alt="Description of photo">`
- **Form labels**: Always associate labels with form controls
- **Heading hierarchy**: Use h1-h6 in logical order
- **Focus management**: Ensure keyboard navigation works
- **Color contrast**: Meet WCAG guidelines (4.5:1 for normal text)

#### Performance Optimization
- **Minimize HTTP requests**: Combine CSS files when possible
- **Optimize images**: Use appropriate formats (WebP, AVIF)
- **Lazy loading**: `<img loading="lazy">` for below-the-fold images
- **Critical CSS**: Inline essential styles for above-the-fold content

### CSS Best Practices

#### Organization and Architecture
```css
/* 1. Reset/Normalize */
* { box-sizing: border-box; }

/* 2. Variables (CSS Custom Properties) */
:root {
    --primary-color: #3498db;
    --secondary-color: #2ecc71;
    --text-color: #333;
    --bg-color: #f4f4f4;
    --font-size-base: 16px;
    --line-height-base: 1.6;
}

/* 3. Base styles */
body {
    font-family: system-ui, sans-serif;
    font-size: var(--font-size-base);
    line-height: var(--line-height-base);
    color: var(--text-color);
    background-color: var(--bg-color);
}

/* 4. Layout components */
.container { max-width: 1200px; margin: 0 auto; }
.grid { display: grid; gap: 1rem; }
.flex { display: flex; align-items: center; }

/* 5. UI components */
.button {
    background: var(--primary-color);
    color: white;
    border: none;
    padding: 0.75rem 1.5rem;
    border-radius: 4px;
    cursor: pointer;
    transition: background-color 0.3s ease;
}

.button:hover { background: var(--secondary-color); }
```

#### Naming Conventions
- **BEM Methodology**: `.block__element--modifier`
- **Utility classes**: `.text-center`, `.mb-2`, `.flex-center`
- **Component-based**: `.card`, `.nav`, `.hero-section`

#### Performance Best Practices
- **Avoid universal selector**: `*` can be expensive
- **Use efficient selectors**: Class selectors are faster than complex descendants
- **Minimize reflows**: Avoid changing layout-affecting properties frequently
- **Use CSS containment**: `contain` property for performance isolation

## 7. Advanced Topics

### CSS Preprocessors
**Sass/SCSS** and **Less** extend CSS with:
- **Variables**: Store reusable values
- **Nesting**: Write hierarchical styles
- **Mixins**: Reusable style patterns
- **Functions**: Dynamic style generation

```scss
// SCSS Example
\$primary-color: #3498db;
\$border-radius: 4px;

@mixin button-style(\$bg-color) {
    background: \$bg-color;
    border: none;
    border-radius: \$border-radius;
    padding: 0.75rem 1.5rem;
    cursor: pointer;
    
    &:hover {
        background: darken(\$bg-color, 10%);
    }
}

.primary-button {
    @include button-style(\$primary-color);
}
```

### Modern CSS Features

#### CSS Grid Advanced Patterns
```css
.grid-layout {
    display: grid;
    grid-template-areas: 
        "header header header"
        "sidebar main aside"
        "footer footer footer";
    grid-template-rows: auto 1fr auto;
    min-height: 100vh;
}

.header { grid-area: header; }
.sidebar { grid-area: sidebar; }
.main { grid-area: main; }
.aside { grid-area: aside; }
.footer { grid-area: footer; }
```

#### CSS Custom Properties (Variables)
```css
/* Define global variables */
:root {
    --primary-color: #3498db;
    --secondary-color: #2ecc71;
    --danger-color: #e74c3c;
    --warning-color: #f39c12;
    --success-color: #27ae60;
    
    --font-family-primary: 'Segoe UI', system-ui, sans-serif;
    --font-family-mono: 'Courier New', monospace;
    
    --spacing-xs: 0.25rem;
    --spacing-sm: 0.5rem;
    --spacing-md: 1rem;
    --spacing-lg: 2rem;
    --spacing-xl: 4rem;
    
    --border-radius-sm: 4px;
    --border-radius-md: 8px;
    --border-radius-lg: 12px;
    
    --shadow-light: 0 2px 4px rgba(0,0,0,0.1);
    --shadow-medium: 0 4px 8px rgba(0,0,0,0.15);
    --shadow-heavy: 0 8px 16px rgba(0,0,0,0.2);
}

/* Use variables throughout the stylesheet */
.card {
    background: white;
    border-radius: var(--border-radius-md);
    box-shadow: var(--shadow-light);
    padding: var(--spacing-lg);
    margin: var(--spacing-md);
}

.button-primary {
    background: var(--primary-color);
    color: white;
    border: none;
    border-radius: var(--border-radius-sm);
    padding: var(--spacing-sm) var(--spacing-md);
    font-family: var(--font-family-primary);
    cursor: pointer;
    transition: all 0.3s ease;
}

.button-primary:hover {
    background: color-mix(in srgb, var(--primary-color) 80%, black);
    box-shadow: var(--shadow-medium);
}
```

### Animation and Transitions

#### CSS Transitions
```css
/* Basic transition properties */
.transition-element {
    background-color: #3498db;
    transform: scale(1);
    opacity: 1;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.transition-element:hover {
    background-color: #2980b9;
    transform: scale(1.05);
    opacity: 0.9;
}

/* Individual property transitions */
.button {
    background-color: var(--primary-color);
    border-radius: var(--border-radius-sm);
    padding: 12px 24px;
    border: 2px solid transparent;
    
    /* Separate transitions for different properties */
    transition: 
        background-color 0.2s ease,
        border-color 0.2s ease,
        transform 0.1s ease;
}

.button:hover {
    background-color: var(--secondary-color);
    border-color: var(--primary-color);
    transform: translateY(-2px);
}
```

#### CSS Animations and Keyframes
```css
/* Define keyframe animations */
@keyframes slideIn {
    0% {
        opacity: 0;
        transform: translateX(-100%);
    }
    50% {
        opacity: 0.5;
        transform: translateX(-20px);
    }
    100% {
        opacity: 1;
        transform: translateX(0);
    }
}

@keyframes pulse {
    0%, 100% {
        transform: scale(1);
        opacity: 1;
    }
    50% {
        transform: scale(1.1);
        opacity: 0.8;
    }
}

@keyframes rotate {
    from {
        transform: rotate(0deg);
    }
    to {
        transform: rotate(360deg);
    }
}

/* Apply animations to elements */
.slide-in {
    animation: slideIn 0.6s ease-out;
}

.loading-spinner {
    animation: rotate 1s linear infinite;
}

.pulse-button {
    animation: pulse 2s ease-in-out infinite;
}

/* Animation with multiple properties */
@keyframes complexMove {
    0% {
        transform: translate(0, 0) scale(1) rotate(0deg);
        background-color: #3498db;
        border-radius: 4px;
    }
    25% {
        transform: translate(50px, 0) scale(1.1) rotate(90deg);
        background-color: #e74c3c;
        border-radius: 50%;
    }
    50% {
        transform: translate(50px, 50px) scale(0.9) rotate(180deg);
        background-color: #2ecc71;
        border-radius: 8px;
    }
    75% {
        transform: translate(0, 50px) scale(1.2) rotate(270deg);
        background-color: #f39c12;
        border-radius: 20px;
    }
    100% {
        transform: translate(0, 0) scale(1) rotate(360deg);
        background-color: #3498db;
        border-radius: 4px;
    }
}

.complex-animation {
    animation: complexMove 4s ease-in-out infinite;
}
```

## 8. Responsive Web Design Deep Dive

### Mobile-First Approach
```css
/* Base styles (mobile first) */
.container {
    padding: 1rem;
    max-width: 100%;
}

.grid {
    display: grid;
    grid-template-columns: 1fr;
    gap: 1rem;
}

.text-size {
    font-size: 1rem;
    line-height: 1.5;
}

/* Tablet styles */
@media (min-width: 768px) {
    .container {
        padding: 2rem;
        max-width: 750px;
        margin: 0 auto;
    }
    
    .grid {
        grid-template-columns: repeat(2, 1fr);
        gap: 1.5rem;
    }
    
    .text-size {
        font-size: 1.125rem;
        line-height: 1.6;
    }
}

/* Desktop styles */
@media (min-width: 1024px) {
    .container {
        max-width: 1200px;
        padding: 3rem;
    }
    
    .grid {
        grid-template-columns: repeat(3, 1fr);
        gap: 2rem;
    }
    
    .text-size {
        font-size: 1.25rem;
        line-height: 1.7;
    }
}

/* Large desktop styles */
@media (min-width: 1440px) {
    .container {
        max-width: 1400px;
        padding: 4rem;
    }
    
    .grid {
        grid-template-columns: repeat(4, 1fr);
        gap: 2.5rem;
    }
}
```

### Flexible Images and Media
```css
/* Responsive images */
.responsive-image {
    max-width: 100%;
    height: auto;
    display: block;
}

/* Picture element with multiple sources */
```

```html
<picture>
    <source media="(min-width: 1024px)" srcset="large-image.webp" type="image/webp">
    <source media="(min-width: 768px)" srcset="medium-image.webp" type="image/webp">
    <source media="(min-width: 1024px)" srcset="large-image.jpg">
    <source media="(min-width: 768px)" srcset="medium-image.jpg">
    <img src="small-image.jpg" alt="Responsive image example" class="responsive-image">
</picture>
```

```css
/* Responsive video */
.video-container {
    position: relative;
    padding-bottom: 56.25%; /* 16:9 aspect ratio */
    height: 0;
    overflow: hidden;
}

.video-container iframe,
.video-container video {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
}

/* Responsive typography */
.responsive-text {
    font-size: clamp(1rem, 2.5vw, 2rem);
    line-height: clamp(1.4, 1.5vw, 1.8);
}
```

## 9. Advanced Layout Techniques

### CSS Grid Advanced Patterns
```css
/* Named grid lines */
.grid-advanced {
    display: grid;
    grid-template-columns: 
        [full-start] minmax(1rem, 1fr)
        [main-start] repeat(12, [col-start] 1fr [col-end])
        [main-end] minmax(1rem, 1fr) [full-end];
    grid-template-rows: repeat(3, auto);
    gap: 2rem;
}

.full-width {
    grid-column: full-start / full-end;
}

.main-content {
    grid-column: main-start / main-end;
}

.sidebar {
    grid-column: col-start 1 / col-end 4;
}

.article {
    grid-column: col-start 5 / col-end 12;
}

/* Grid areas with complex layouts */
.magazine-layout {
    display: grid;
    grid-template-areas: 
        "header header header header"
        "featured featured sidebar1 sidebar2"
        "article1 article2 sidebar1 sidebar2"
        "article3 article3 article3 newsletter"
        "footer footer footer footer";
    grid-template-columns: 2fr 2fr 1fr 1fr;
    grid-template-rows: auto 300px auto 200px auto;
    gap: 2rem;
    max-width: 1200px;
    margin: 0 auto;
    padding: 2rem;
}

.header { grid-area: header; }
.featured { grid-area: featured; }
.sidebar1 { grid-area: sidebar1; }
.sidebar2 { grid-area: sidebar2; }
.article1 { grid-area: article1; }
.article2 { grid-area: article2; }
.article3 { grid-area: article3; }
.newsletter { grid-area: newsletter; }
.footer { grid-area: footer; }

/* Responsive grid areas */
@media (max-width: 768px) {
    .magazine-layout {
        grid-template-areas: 
            "header"
            "featured"
            "article1"
            "article2"
            "sidebar1"
            "sidebar2"
            "article3"
            "newsletter"
            "footer";
        grid-template-columns: 1fr;
        grid-template-rows: repeat(9, auto);
    }
}
```

### Flexbox Advanced Patterns
```css
/* Holy grail layout with flexbox */
.holy-grail {
    display: flex;
    flex-direction: column;
    min-height: 100vh;
}

.holy-grail-header,
.holy-grail-footer {
    background: #2c3e50;
    color: white;
    padding: 1rem;
    flex: none;
}

.holy-grail-body {
    display: flex;
    flex: 1;
}

.holy-grail-content {
    flex: 1;
    padding: 2rem;
    background: white;
}

.holy-grail-nav,
.holy-grail-ads {
    flex: 0 0 200px;
    background: #ecf0f1;
    padding: 1rem;
}

.holy-grail-nav {
    order: -1;
}

/* Responsive flex layout */
@media (max-width: 768px) {
    .holy-grail-body {
        flex-direction: column;
    }
    
    .holy-grail-nav,
    .holy-grail-ads {
        flex: none;
        order: 0;
    }
}

/* Card layout with equal heights */
.card-container {
    display: flex;
    flex-wrap: wrap;
    gap: 2rem;
    align-items: stretch;
}

.card {
    flex: 1 1 300px;
    display: flex;
    flex-direction: column;
    background: white;
    border-radius: 8px;
    box-shadow: 0 4px 8px rgba(0,0,0,0.1);
    overflow: hidden;
}

.card-header {
    padding: 1.5rem;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
}

.card-body {
    padding: 1.5rem;
    flex-grow: 1;
}

.card-footer {
    padding: 1rem 1.5rem;
    background: #f8f9fa;
    margin-top: auto;
}
```

## 10. CSS Architecture and Methodologies

### BEM (Block Element Modifier)
```css
/* Block */
.button {
    display: inline-block;
    padding: 12px 24px;
    border: none;
    border-radius: 4px;
    font-family: inherit;
    font-size: 1rem;
    text-decoration: none;
    cursor: pointer;
    transition: all 0.3s ease;
}

/* Elements */
.button__icon {
    margin-right: 8px;
    font-size: 0.875rem;
}

.button__text {
    font-weight: 500;
}

/* Modifiers */
.button--primary {
    background-color: #3498db;
    color: white;
}

.button--primary:hover {
    background-color: #2980b9;
}

.button--secondary {
    background-color: #95a5a6;
    color: white;
}

.button--large {
    padding: 16px 32px;
    font-size: 1.125rem;
}

.button--small {
    padding: 8px 16px;
    font-size: 0.875rem;
}

.button--full-width {
    width: 100%;
    display: block;
}

/* Combined modifiers */
.button--primary.button--large {
    box-shadow: 0 4px 8px rgba(52, 152, 219, 0.3);
}
```

### CSS Modules Approach
```css
/* Component-scoped styles */
.component {
    /* Base component styles */
}

.component .title {
    font-size: 1.5rem;
    font-weight: 600;
    margin-bottom: 1rem;
    color: #2c3e50;
}

.component .description {
    font-size: 1rem;
    line-height: 1.6;
    color: #7f8c8d;
    margin-bottom: 2rem;
}

.component .actions {
    display: flex;
    gap: 1rem;
    justify-content: flex-end;
}
```

### Utility-First CSS
```css
/* Utility classes for common patterns */
.flex { display: flex; }
.flex-col { flex-direction: column; }
.flex-wrap { flex-wrap: wrap; }
.items-center { align-items: center; }
.justify-center { justify-content: center; }
.justify-between { justify-content: space-between; }

.grid { display: grid; }
.grid-cols-1 { grid-template-columns: repeat(1, 1fr); }
.grid-cols-2 { grid-template-columns: repeat(2, 1fr); }
.grid-cols-3 { grid-template-columns: repeat(3, 1fr); }
.grid-cols-4 { grid-template-columns: repeat(4, 1fr); }

.gap-1 { gap: 0.25rem; }
.gap-2 { gap: 0.5rem; }
.gap-4 { gap: 1rem; }
.gap-8 { gap: 2rem; }

.p-1 { padding: 0.25rem; }
.p-2 { padding: 0.5rem; }
.p-4 { padding: 1rem; }
.p-8 { padding: 2rem; }

.m-1 { margin: 0.25rem; }
.m-2 { margin: 0.5rem; }
.m-4 { margin: 1rem; }
.m-auto { margin: auto; }

.text-sm { font-size: 0.875rem; }
.text-base { font-size: 1rem; }
.text-lg { font-size: 1.125rem; }
.text-xl { font-size: 1.25rem; }
.text-2xl { font-size: 1.5rem; }

.font-normal { font-weight: 400; }
.font-medium { font-weight: 500; }
.font-semibold { font-weight: 600; }
.font-bold { font-weight: 700; }

.text-gray-500 { color: #6b7280; }
.text-gray-700 { color: #374151; }
.text-gray-900 { color: #111827; }

.bg-white { background-color: white; }
.bg-gray-50 { background-color: #f9fafb; }
.bg-gray-100 { background-color: #f3f4f6; }

.rounded { border-radius: 0.25rem; }
.rounded-md { border-radius: 0.375rem; }
.rounded-lg { border-radius: 0.5rem; }
.rounded-full { border-radius: 9999px; }

.shadow { box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1); }
.shadow-md { box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1); }
.shadow-lg { box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1); }
```

## 11. Performance Optimization

### Critical CSS Strategy
```css
/* Critical above-the-fold styles - inline in <head> */
body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
    line-height: 1.6;
    color: #333;
    margin: 0;
    padding: 0;
}

.header {
    background: #2c3e50;
    color: white;
    padding: 1rem 0;
}

.hero {
    min-height: 60vh;
    display: flex;
    align-items: center;
    justify-content: center;
    text-align: center;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
}

.hero h1 {
    font-size: clamp(2rem, 5vw, 4rem);
    margin-bottom: 1rem;
}

/* Non-critical styles loaded asynchronously */
.footer,
.sidebar,
.comments {
    /* These can be loaded later */
}
```

### CSS Optimization Techniques
```css
/* Efficient selectors */
/* ✅ Good - class selectors are fast */
.navigation-item { }
.button-primary { }
.card-header { }

/* ❌ Avoid - complex descendant selectors */
.header .navigation .menu .item .link { }

/* ✅ Good - use specific classes instead */
.nav-link { }

/* Efficient animations */
.optimized-animation {
    /* Use transform and opacity for smooth animations */
    transform: translateX(0);
    opacity: 1;
    transition: transform 0.3s ease, opacity 0.3s ease;
}

.optimized-animation:hover {
    transform: translateX(10px);
    opacity: 0.8;
}

/* Avoid animating layout properties */
.avoid-this {
    transition: width 0.3s ease; /* Causes layout recalculation */
}

/* CSS containment for performance */
.contained-component {
    contain: layout style paint;
}

.isolated-component {
    contain: strict;
}
```

## 12. Modern CSS Features

### Container Queries
```css
/* Container query setup */
.card-container {
    container-type: inline-size;
    container-name: card;
}

.card {
    padding: 1rem;
    background: white;
    border-radius: 8px;
}

/* Style based on container size, not viewport */
@container card (min-width: 300px) {
    .card {
        display: flex;
        gap: 1rem;
    }
    
    .card-image {
        flex: 0 0 100px;
    }
    
    .card-content {
        flex: 1;
    }
}

@container card (min-width: 500px) {
    .card {
        padding: 2rem;
    }
    
    .card-image {
        flex: 0 0 150px;
    }
}
```

### CSS Logical Properties
```css
/* Traditional physical properties */
.traditional {
    margin-top: 1rem;
    margin-right: 2rem;
    margin-bottom: 1rem;
    margin-left: 2rem;
    border-left: 2px solid blue;
    text-align: left;
}

/* Modern logical properties (better for internationalization) */
.logical {
    margin-block-start: 1rem;
    margin-inline-end: 2rem;
    margin-block-end: 1rem;
    margin-inline-start: 2rem;
    border-inline-start: 2px solid blue;
    text-align: start;
}

/* Shorthand logical properties */
.shorthand-logical {
    margin-block: 1rem; /* top and bottom */
    margin-inline: 2rem; /* left and right */
    padding-block: 0.5rem;
    padding-inline: 1rem;
    border-inline: 1px solid #ccc;
}
```

### CSS Scroll Snap
```css
.scroll-container {
    scroll-snap-type: x mandatory;
    display: flex;
    overflow-x: auto;
    gap: 1rem;
    padding: 1rem;
}

.scroll-item {
    scroll-snap-align: start;
    flex: 0 0 300px;
    height: 200px;
    background: linear-gradient(45deg, #667eea, #764ba2);
    border-radius: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 1.5rem;
}

/* Vertical scroll snap */
.vertical-scroll {
    height: 100vh;
    overflow-y: auto;
    scroll-snap-type: y mandatory;
}

.section {
    height: 100vh;
    scroll-snap-align: start;
    display: flex;
    align-items: center;
    justify-content: center;
}
```

## 13. Web Accessibility and Inclusive Design

### Understanding web accessibility
Web accessibility ensures that websites and applications are usable by people with disabilities, including visual, auditory, motor, and cognitive impairments. This creates inclusive digital experiences for everyone.

#### Essential accessibility principles
- **Perceivable**: Information must be presentable in ways users can perceive
- **Operable**: Interface components must be operable by all users
- **Understandable**: Information and UI operation must be understandable
- **Robust**: Content must be robust enough for various assistive technologies

### HTML accessibility features
```html
<!-- Semantic HTML structure -->
<main role="main">
    <nav aria-label="Primary navigation">
        <ul>
            <li><a href="#home" aria-current="page">Home</a></li>
            <li><a href="#about">About</a></li>
            <li><a href="#contact">Contact</a></li>
        </ul>
    </nav>
    
    <!-- Accessible forms -->
    <form>
        <label for="email">Email address (required)</label>
        <input 
            type="email" 
            id="email" 
            name="email" 
            required 
            aria-describedby="email-help"
        >
        <div id="email-help">We'll never share your email</div>
        
        <button type="submit" aria-describedby="submit-info">
            Subscribe to Newsletter
        </button>
        <div id="submit-info" class="sr-only">
            Submit form to join our mailing list
        </div>
    </form>
</main>
```

### CSS for accessibility
```css
/* Focus indicators for keyboard navigation */
:focus {
    outline: 2px solid #0066cc;
    outline-offset: 2px;
}

/* High contrast support */
@media (prefers-contrast: high) {
    .card {
        border: 2px solid;
        box-shadow: none;
    }
}

/* Reduced motion preferences */
@media (prefers-reduced-motion: reduce) {
    * {
        animation-duration: 0.01ms !important;
        animation-iteration-count: 1 !important;
        transition-duration: 0.01ms !important;
    }
}

/* Screen reader only content */
.sr-only {
    position: absolute;
    width: 1px;
    height: 1px;
    padding: 0;
    margin: -1px;
    overflow: hidden;
    clip: rect(0, 0, 0, 0);
    white-space: nowrap;
}

/* Dark mode support */
@media (prefers-color-scheme: dark) {
    :root {
        --bg-color: #1a1a1a;
        --text-color: #ffffff;
        --link-color: #66b3ff;
    }
}
```

## 14. Modern CSS Layout Techniques

### Advanced grid layouts
```css
/* Complex grid areas */
.magazine-layout {
    display: grid;
    grid-template-areas: 
        "header header header"
        "featured sidebar1 sidebar2"
        "article1 article2 sidebar2"
        "article3 article3 newsletter"
        "footer footer footer";
    grid-template-columns: 2fr 1fr 1fr;
    grid-template-rows: auto 300px auto 200px auto;
    gap: 2rem;
}

.header { grid-area: header; }
.featured { grid-area: featured; }
.sidebar1 { grid-area: sidebar1; }
.sidebar2 { grid-area: sidebar2; }
.article1 { grid-area: article1; }
.article2 { grid-area: article2; }
.article3 { grid-area: article3; }
.newsletter { grid-area: newsletter; }
.footer { grid-area: footer; }

/* Responsive grid adjustments */
@media (max-width: 768px) {
    .magazine-layout {
        grid-template-areas: 
            "header"
            "featured"
            "article1"
            "article2"
            "sidebar1"
            "sidebar2"
            "article3"
            "newsletter"
            "footer";
        grid-template-columns: 1fr;
    }
}
```

### Flexbox patterns
```css
/* Holy grail layout */
.holy-grail {
    display: flex;
    flex-direction: column;
    min-height: 100vh;
}

.holy-grail-header,
.holy-grail-footer {
    flex: none;
    background: #333;
    color: white;
    padding: 1rem;
}

.holy-grail-body {
    display: flex;
    flex: 1;
}

.holy-grail-content {
    flex: 1;
    padding: 2rem;
}

.holy-grail-nav,
.holy-grail-ads {
    flex: 0 0 200px;
    background: #f5f5f5;
    padding: 1rem;
}

/* Card layouts with equal heights */
.card-container {
    display: flex;
    flex-wrap: wrap;
    gap: 2rem;
}

.card {
    flex: 1 1 300px;
    display: flex;
    flex-direction: column;
    background: white;
    border-radius: 8px;
    box-shadow: 0 4px 8px rgba(0,0,0,0.1);
}

.card-body {
    flex-grow: 1;
    padding: 1.5rem;
}

.card-footer {
    padding: 1rem;
    background: #f8f9fa;
    margin-top: auto;
}
```

## 15. CSS Performance Optimization

### Efficient selectors and properties
```css
/* Efficient CSS practices */
/* Use class selectors (fast) */
.navigation-item { }
.button-primary { }

/* Avoid expensive selectors */
/* * { } Universal selector (slow) */
/* [attribute] { } Unqualified attribute (slow) */
/* div > * { } Universal child (slow) */

/* Optimize animations */
.optimized-animation {
    /* Use transform and opacity (GPU accelerated) */
    transform: translateX(0);
    opacity: 1;
    transition: transform 0.3s ease, opacity 0.3s ease;
}

.optimized-animation:hover {
    transform: translateX(10px);
    opacity: 0.8;
}

/* Avoid layout-triggering properties in animations */
/* width, height, top, left, margin, padding (cause reflow) */

/* CSS containment for performance isolation */
.contained-widget {
    contain: layout style paint;
}

.strict-containment {
    contain: strict;
}
```

### Critical CSS strategy
```css
/* Critical above-the-fold styles */
body {
    font-family: system-ui, -apple-system, sans-serif;
    line-height: 1.6;
    margin: 0;
    color: #333;
}

.header {
    background: #2c3e50;
    color: white;
    padding: 1rem 0;
}

.hero {
    min-height: 60vh;
    display: flex;
    align-items: center;
    justify-content: center;
    background: linear-gradient(135deg, #667eea, #764ba2);
    color: white;
}

/* Non-critical styles loaded separately */
/* .sidebar, .footer, .comments, etc. */
```

## 16. Modern CSS Features

### Container queries
```css
.card-container {
    container-type: inline-size;
    container-name: card;
}

.card {
    padding: 1rem;
    background: white;
    border-radius: 8px;
}

/* Style based on container size, not viewport */
@container card (min-width: 300px) {
    .card {
        display: flex;
        gap: 1rem;
    }
    
    .card-image {
        flex: 0 0 100px;
    }
}

@container card (min-width: 500px) {
    .card {
        padding: 2rem;
    }
    
    .card-image {
        flex: 0 0 150px;
    }
}
```

### CSS scroll snap
```css
.scroll-container {
    scroll-snap-type: x mandatory;
    display: flex;
    overflow-x: auto;
    gap: 1rem;
}

.scroll-item {
    scroll-snap-align: start;
    flex: 0 0 300px;
    height: 200px;
    background: linear-gradient(45deg, #667eea, #764ba2);
    border-radius: 8px;
}

/* Vertical scroll snap */
.section {
    height: 100vh;
    scroll-snap-align: start;
}
```

### CSS logical properties
```css
/* Traditional physical properties */
.traditional {
    margin-top: 1rem;
    margin-right: 2rem;
    margin-bottom: 1rem;
    margin-left: 2rem;
}

/* Modern logical properties (better for i18n) */
.logical {
    margin-block-start: 1rem;
    margin-inline-end: 2rem;
    margin-block-end: 1rem;
    margin-inline-start: 2rem;
}

/* Shorthand logical properties */
.shorthand {
    margin-block: 1rem; /* top and bottom */
    margin-inline: 2rem; /* left and right */
    padding-block: 0.5rem;
    padding-inline: 1rem;
}
```

## 17. CSS Architecture and Methodologies

### BEM (Block Element Modifier)
```css
/* Block */
.button {
    display: inline-block;
    padding: 12px 24px;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-family: inherit;
}

/* Elements */
.button__icon {
    margin-right: 8px;
}

.button__text {
    font-weight: 500;
}

/* Modifiers */
.button--primary {
    background: #3498db;
    color: white;
}

.button--large {
    padding: 16px 32px;
    font-size: 1.125rem;
}

.button--full-width {
    width: 100%;
    display: block;
}
```

### Utility-first approach
```css
/* Utility classes */
.flex { display: flex; }
.flex-col { flex-direction: column; }
.items-center { align-items: center; }
.justify-between { justify-content: space-between; }

.p-1 { padding: 0.25rem; }
.p-2 { padding: 0.5rem; }
.p-4 { padding: 1rem; }

.m-1 { margin: 0.25rem; }
.m-2 { margin: 0.5rem; }
.m-auto { margin: auto; }

.text-sm { font-size: 0.875rem; }
.text-base { font-size: 1rem; }
.text-lg { font-size: 1.125rem; }

.font-normal { font-weight: 400; }
.font-medium { font-weight: 500; }
.font-bold { font-weight: 700; }

.rounded { border-radius: 0.25rem; }
.rounded-lg { border-radius: 0.5rem; }
.rounded-full { border-radius: 9999px; }

.shadow { box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
.shadow-lg { box-shadow: 0 10px 15px rgba(0,0,0,0.1); }
```

## 18. Testing and Quality Assurance

### Cross-browser compatibility
```css
/* Progressive enhancement */
.modern-grid {
    /* Fallback for older browsers */
    display: block;
    
    /* Modern browsers */
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
}

/* Feature queries */
@supports (display: grid) {
    .grid-layout {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
    }
}

@supports not (display: grid) {
    .grid-layout {
        display: flex;
        flex-wrap: wrap;
    }
}

/* Vendor prefixes when needed */
.transform-element {
    -webkit-transform: rotate(45deg);
    -moz-transform: rotate(45deg);
    transform: rotate(45deg);
}
```

### CSS validation
```css
/* Valid CSS practices */
.valid-styles {
    /* Use standard property names */
    background-color: #ffffff;
    
    /* Include units for non-zero values */
    margin: 0; /* Zero doesn't need unit */
    padding: 10px; /* Non-zero needs unit */
    
    /* Use proper color formats */
    color: #333333; /* Hex */
    border-color: rgb(255, 0, 0); /* RGB */
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1); /* RGBA */
}
```

Remember: HTML and CSS form the foundation of all web development. Master these technologies through consistent practice, real-world projects, and staying current with modern web standards. Focus on semantic markup, accessible design, performance optimization, and responsive layouts to create exceptional user experiences across all devices and user abilities.

.card {
    background: var(--bg, white);
    color: var(--text, black);
    border: 1px solid var(--primary);
}
```

#### CSS Animations and Transitions
```css
@keyframes slideIn {
    from {
        transform: translateX(-100%);
        opacity: 0;
    }
    to {
        transform: translateX(0);
        opacity: 1;
    }
}

.slide-in {
    animation: slideIn 0.5s ease-out;
}

.smooth-hover {
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.smooth-hover:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 25px rgba(0,0,0,0.2);
}
```

### Progressive Enhancement
- **Start with semantic HTML**: Works without CSS/JS
- **Add CSS**: Enhanced visual presentation
- **Add JavaScript**: Interactive functionality
- **Graceful degradation**: Fallbacks for unsupported features

## 8. Summary and Key Takeaways

### Essential Concepts to Master
- **HTML Semantics**: Use elements for their intended purpose
- **CSS Box Model**: Understand how elements are sized and spaced
- **Flexbox and Grid**: Modern layout techniques for responsive design
- **Responsive Design**: Mobile-first approach with media queries
- **Accessibility**: Build inclusive experiences for all users
- **Performance**: Optimize for speed and user experience

### Development Workflow
1. **Plan structure**: Start with semantic HTML outline
2. **Style systematically**: Base styles → Layout → Components → Details
3. **Test across devices**: Use browser dev tools and real devices
4. **Validate code**: Use HTML/CSS validators and accessibility checkers
5. **Optimize performance**: Minimize, compress, and optimize assets

### Next Steps in Web Development
- **JavaScript**: Add interactivity and dynamic behavior
- **CSS Frameworks**: Bootstrap, Tailwind CSS for rapid development
- **Build Tools**: Webpack, Vite, Parcel for modern workflows
- **Version Control**: Git for collaborative development
- **Deployment**: Hosting, CDNs, and production optimization

### Career Applications
- **Front-end Developer**: User interface implementation
- **UX/UI Designer**: Design systems and prototyping
- **Full-stack Developer**: Complete web application development
- **Technical Writer**: Documentation and tutorial creation
- **Digital Marketing**: Landing pages and email templates

**Remember**: HTML and CSS are the foundation of all web development. Master these fundamentals, and you'll have a solid base for any web technology you choose to learn next!''';

      case 'simplified':
        return '''# 🌐 HTML and CSS - Simplified Guide

## 🎯 What is HTML and CSS?

**HTML** (*HyperText Markup Language*) is like the **skeleton** of a webpage - it creates the structure and organizes content. Think of it as the *blueprint* of a house.

**CSS** (*Cascading Style Sheets*) is like the **paint and decoration** - it makes websites look beautiful with colors, fonts, and layouts. Think of it as the *interior design* of the house.

> **Simple Analogy**: If a webpage were a house, HTML would be the walls and rooms, and CSS would be the paint, furniture, and decorations!

## 🔑 Key Points to Remember

### HTML Essentials
• **Tags**: The building blocks like `<h1>`, `<p>`, `<div>`, `<img>`
• **Structure**: Every webpage starts with `<html>`, `<head>`, and `<body>`
• **Content**: Text, images, links, and forms go inside HTML tags
• **Semantic**: Use **meaningful tags** like `<header>`, `<nav>`, `<main>`

### CSS Essentials  
• **Selectors**: Target HTML elements to style (like `h1`, `.class`, `#id`)
• **Properties**: Style attributes like `color`, `font-size`, `margin`
• **Box Model**: Every element has **content**, **padding**, **border**, **margin**
• **Responsive**: Make websites work on **phones**, **tablets**, and **desktops**

### How They Work Together
• **HTML** creates the content and structure
• **CSS** makes it look good and responsive
• **Best Practice**: Keep HTML *semantic* and CSS *organized*
• **Modern Approach**: Use **Flexbox** and **Grid** for layouts

## 📚 Quick Learning Steps

### 1. **Start with HTML Basics**
   - Learn essential tags: `<h1>-<h6>`, `<p>`, `<div>`, `<span>`
   - Practice creating simple pages
   - Understand document structure

### 2. **Add CSS Styling**
   - Learn basic properties: `color`, `background`, `font-size`
   - Practice selecting elements
   - Experiment with the box model

### 3. **Master Layouts**
   - Learn **Flexbox** for one-dimensional layouts
   - Learn **CSS Grid** for two-dimensional layouts
   - Practice responsive design with **media queries**

### 4. **Build Real Projects**
   - Create a personal portfolio website
   - Build a simple blog layout
   - Practice with form styling

## 🏆 Why Learn This?

### **Career Benefits**
• **Front-end Developer**: \$60,000-\$120,000+ annually
• **Web Designer**: Essential skill for all design roles
• **Freelancing**: Build websites for local businesses
• **Side Projects**: Create your own websites and apps

### **Practical Applications**
• **Personal websites**: Portfolio, blog, business site
• **E-commerce**: Online stores and product pages
• **Mobile apps**: Web-based mobile applications
• **Email templates**: HTML emails for marketing

### **Creative Opportunities**
• **Visual Design**: Bring your creative ideas to life
• **User Experience**: Create intuitive, beautiful interfaces
• **Problem Solving**: Debug layout and styling issues
• **Continuous Learning**: Web technologies are always evolving

## ⚡ Quick Facts

### **HTML Stats**
• **Created**: 1990 by Tim Berners-Lee
• **Current Version**: HTML5 (released 2014)
• **Elements**: 100+ different HTML tags available
• **Usage**: **100%** of websites use HTML

### **CSS Stats**
• **Created**: 1996 by Håkon Wium Lie
• **Current Version**: CSS3 (modular releases)
• **Properties**: 500+ CSS properties available  
• **Adoption**: **96%** of websites use CSS

### **Industry Facts**
• **Mobile Traffic**: 60%+ of web traffic is mobile
• **Page Load Time**: Users expect sites to load in under 3 seconds
• **Accessibility**: 15% of population has some form of disability
• **Responsive Design**: Essential for modern web development

## 🛠️ Getting Started

### **Required Tools** (All Free!)
• **Text Editor**: VS Code, Sublime Text, or Atom
• **Web Browser**: Chrome, Firefox, or Edge (with dev tools)
• **File Structure**: Organize HTML, CSS, and image files
• **Version Control**: Git for tracking code changes (optional but recommended)

### **First Steps**
1. **Install VS Code** with HTML/CSS extensions
2. **Create your first HTML file**: `index.html`
3. **Add basic CSS**: Either inline, internal, or external
4. **Open in browser**: See your webpage come to life!

### **Practice Resources**
• **CodePen**: Online playground for HTML/CSS experiments
• **MDN Web Docs**: Comprehensive reference and tutorials
• **freeCodeCamp**: Free interactive lessons
• **YouTube Tutorials**: Visual learning with step-by-step guides

### **Project Ideas for Beginners**
• **Personal Card**: Simple business card webpage
• **Recipe Page**: Style a favorite recipe with images
• **Simple Portfolio**: Showcase your projects and skills
• **Landing Page**: Create a promotional page for anything

## 💡 Pro Tips for Success

### **Learning Best Practices**
• **Start Small**: Build simple pages before complex layouts
• **Practice Daily**: Even 15 minutes daily builds muscle memory
• **Copy and Modify**: Learn from existing websites you admire
• **Use Dev Tools**: Browser developer tools are your best friend

### **Common Mistakes to Avoid**
• **Don't use tables for layout**: Use CSS Grid or Flexbox instead
• **Avoid inline styles**: Keep CSS separate for maintainability  
• **Don't ignore mobile**: Always design mobile-first
• **Skip the !important**: Learn CSS specificity instead

### **Time-Saving Techniques**
• **CSS Reset**: Start with consistent base styles
• **Utility Classes**: Create reusable CSS classes
• **Code Snippets**: Save common patterns for reuse
• **Browser Extensions**: Use tools like ColorZilla, WhatFont

### **Professional Development**
• **Join Communities**: Stack Overflow, CSS-Tricks, Dev.to
• **Follow Industry Leaders**: CSS experts on Twitter/LinkedIn
• **Build Portfolio**: Showcase your best work online
• **Keep Learning**: Web standards and trends change regularly

## 🎉 Encouragement

**Remember**: Every expert was once a beginner! 

• **HTML and CSS** are **learnable skills** - not magic
• **Practice makes perfect** - build lots of small projects
• **Mistakes are learning opportunities** - every developer makes them
• **The community is helpful** - don't hesitate to ask questions
• **Your first website won't be perfect** - and that's okay!

> **Success Tip**: Focus on understanding the **fundamentals** rather than memorizing every property. The reference docs will always be there when you need them!

**Start your web development journey today** - your future self will thank you! 🚀''';

      case 'quiz':
        return '''## Quiz: HTML and CSS Foundations

### Question 1
What does HTML stand for?
A) High Tech Markup Language
B) HyperText Markup Language
C) Home Tool Markup Language
D) Hyperlink Text Markup Language

**Answer: B) HyperText Markup Language**

### Question 2
Which CSS property changes text color?
A) text-color
B) color
C) font-color
D) text-style

**Answer: B) color**

### Question 3
What is the correct way to link CSS to HTML?
A) `<style src="style.css">`
B) `<link rel="stylesheet" href="style.css">`
C) `<css href="style.css">`
D) `<stylesheet src="style.css">`

**Answer: B) `<link rel="stylesheet" href="style.css">`**

### Question 4
Which HTML element is used for the largest heading?
A) `<h6>`
B) `<header>`
C) `<h1>`
D) `<title>`

**Answer: C) `<h1>`**

### Question 5
What does CSS stand for?
A) Creative Style Sheets
B) Cascading Style Sheets
C) Computer Style Sheets
D) Colorful Style Sheets

**Answer: B) Cascading Style Sheets**''';

      case 'examples':
        return '''# 🚀 Practical HTML & CSS Examples

## 📋 Table of Contents
1. [Basic Structure](#basic-structure)
2. [Styling Fundamentals](#styling-fundamentals)
3. [Layout Techniques](#layout-techniques)
4. [Interactive Components](#interactive-components)
5. [Real-World Projects](#real-world-projects)

---

## 🏗️ Basic Structure Examples

### Example 1: Complete HTML5 Document
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="My first professional webpage">
    <title>Professional Portfolio | Jane Doe</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <header class="main-header">
        <nav class="navbar">
            <div class="logo">Jane Doe</div>
            <ul class="nav-links">
                <li><a href="#home">Home</a></li>
                <li><a href="#about">About</a></li>
                <li><a href="#portfolio">Portfolio</a></li>
                <li><a href="#contact">Contact</a></li>
            </ul>
        </nav>
    </header>

    <main>
        <section id="hero" class="hero-section">
            <h1>Welcome to My Portfolio</h1>
            <p class="hero-subtitle">Frontend Developer & Designer</p>
            <button class="cta-button">View My Work</button>
        </section>
    </main>

    <footer class="main-footer">
        <p>&copy; 2024 Jane Doe. All rights reserved.</p>
    </footer>
</body>
</html>
```

**💡 Key Points:**
- Complete HTML5 structure with semantic elements
- Proper meta tags for SEO and responsive design
- Semantic navigation and content organization
- Accessibility-friendly markup

### Example 2: Semantic HTML Form
```html
<form class="contact-form" action="/submit" method="POST">
    <fieldset>
        <legend>Contact Information</legend>
        
        <div class="form-group">
            <label for="full-name">Full Name *</label>
            <input type="text" id="full-name" name="fullName" required
                   placeholder="Enter your full name">
        </div>
        
        <div class="form-group">
            <label for="email">Email Address *</label>
            <input type="email" id="email" name="email" required
                   placeholder="john@example.com">
        </div>
        
        <div class="form-group">
            <label for="message">Message</label>
            <textarea id="message" name="message" rows="5"
                      placeholder="Tell us about your project..."></textarea>
        </div>
        
        <div class="form-actions">
            <button type="submit" class="submit-btn">Send Message</button>
            <button type="reset" class="reset-btn">Clear Form</button>
        </div>
    </fieldset>
</form>
```

**💡 Key Points:**
- Proper form structure with fieldset and legend
- Associated labels with form controls
- Input validation and accessibility features
- Semantic button types

---

## 🎨 Styling Fundamentals

### Example 3: Modern CSS with Custom Properties
```css
/* CSS Custom Properties (Variables) */
:root {
    --primary-color: #3498db;
    --secondary-color: #2ecc71;
    --accent-color: #e74c3c;
    --text-dark: #2c3e50;
    --text-light: #7f8c8d;
    --bg-light: #ecf0f1;
    --shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    --border-radius: 8px;
    --transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

/* Modern CSS Reset */
*, *::before, *::after {
    box-sizing: border-box;
}

body {
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
    line-height: 1.6;
    color: var(--text-dark);
    background-color: var(--bg-light);
    margin: 0;
}

/* Component Styling */
.hero-section {
    background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
    color: white;
    padding: 4rem 2rem;
    text-align: center;
    min-height: 100vh;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
}

.cta-button {
    background: var(--accent-color);
    color: white;
    border: none;
    padding: 1rem 2rem;
    border-radius: var(--border-radius);
    font-size: 1.1rem;
    font-weight: 600;
    cursor: pointer;
    transition: var(--transition);
    box-shadow: var(--shadow);
}

.cta-button:hover {
    background: #c0392b;
    transform: translateY(-2px);
    box-shadow: 0 6px 12px rgba(0, 0, 0, 0.15);
}
```

**💡 Key Points:**
- CSS custom properties for maintainable code
- Modern CSS reset for consistent styling
- Smooth transitions and hover effects
- Professional color scheme and typography

### Example 4: Responsive Grid Layout
```css
.portfolio-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 2rem;
    padding: 2rem;
    max-width: 1200px;
    margin: 0 auto;
}

.portfolio-item {
    background: white;
    border-radius: var(--border-radius);
    overflow: hidden;
    box-shadow: var(--shadow);
    transition: var(--transition);
}

.portfolio-item:hover {
    transform: translateY(-5px);
    box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}

.portfolio-item img {
    width: 100%;
    height: 200px;
    object-fit: cover;
    display: block;
}

.portfolio-content {
    padding: 1.5rem;
}

.portfolio-title {
    font-size: 1.25rem;
    font-weight: 600;
    margin-bottom: 0.5rem;
    color: var(--text-dark);
}

.portfolio-description {
    color: var(--text-light);
    margin-bottom: 1rem;
}

.portfolio-tags {
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem;
}

.tag {
    background: var(--bg-light);
    color: var(--text-dark);
    padding: 0.25rem 0.75rem;
    border-radius: 20px;
    font-size: 0.875rem;
    font-weight: 500;
}
```

**💡 Key Points:**
- CSS Grid with responsive auto-fit columns
- Card component with hover animations
- Image optimization with object-fit
- Flexible tag system with flexbox

---

## 📱 Responsive Design Examples

### Example 5: Mobile-First Responsive Navigation
```css
/* Mobile First - Base Styles */
.navbar {
    background: white;
    box-shadow: var(--shadow);
    padding: 1rem;
    position: sticky;
    top: 0;
    z-index: 100;
}

.nav-container {
    display: flex;
    justify-content: space-between;
    align-items: center;
    max-width: 1200px;
    margin: 0 auto;
}

.logo {
    font-size: 1.5rem;
    font-weight: 700;
    color: var(--primary-color);
    text-decoration: none;
}

.nav-menu {
    position: fixed;
    top: 70px;
    left: -100%;
    width: 100%;
    height: calc(100vh - 70px);
    background: white;
    flex-direction: column;
    justify-content: flex-start;
    align-items: center;
    transition: var(--transition);
    padding: 2rem 0;
}

.nav-menu.active {
    left: 0;
}

.nav-link {
    display: block;
    padding: 1rem 2rem;
    color: var(--text-dark);
    text-decoration: none;
    font-weight: 500;
    transition: var(--transition);
    border-bottom: 1px solid var(--bg-light);
    width: 100%;
    text-align: center;
}

.nav-link:hover {
    background: var(--bg-light);
    color: var(--primary-color);
}

.hamburger {
    display: flex;
    flex-direction: column;
    cursor: pointer;
    padding: 0.5rem;
}

.hamburger span {
    width: 25px;
    height: 3px;
    background: var(--text-dark);
    margin: 3px 0;
    transition: var(--transition);
    border-radius: 3px;
}

/* Tablet and Desktop */
@media screen and (min-width: 768px) {
    .nav-menu {
        position: static;
        flex-direction: row;
        height: auto;
        background: transparent;
        padding: 0;
        width: auto;
        left: 0;
    }
    
    .nav-link {
        border-bottom: none;
        padding: 0.5rem 1rem;
        width: auto;
    }
    
    .hamburger {
        display: none;
    }
}
```

**💡 Key Points:**
- Mobile-first responsive approach
- Smooth hamburger menu animation
- Sticky navigation with z-index management
- Progressive enhancement for larger screens

---

## 🛠️ Interactive Components

### Example 6: CSS-Only Modal Dialog
```html
<div class="modal-container">
    <input type="checkbox" id="modal-toggle" class="modal-toggle">
    <label for="modal-toggle" class="modal-trigger">Open Modal</label>
    
    <div class="modal-overlay">
        <div class="modal-content">
            <label for="modal-toggle" class="modal-close">&times;</label>
            <h2>Modal Title</h2>
            <p>This is a CSS-only modal dialog. No JavaScript required!</p>
            <div class="modal-actions">
                <button class="btn btn-primary">Confirm</button>
                <label for="modal-toggle" class="btn btn-secondary">Cancel</label>
            </div>
        </div>
    </div>
</div>
```

```css
.modal-toggle {
    display: none;
}

.modal-trigger {
    display: inline-block;
    background: var(--primary-color);
    color: white;
    padding: 0.75rem 1.5rem;
    border-radius: var(--border-radius);
    cursor: pointer;
    transition: var(--transition);
    text-decoration: none;
}

.modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.7);
    display: flex;
    justify-content: center;
    align-items: center;
    opacity: 0;
    visibility: hidden;
    transition: var(--transition);
    z-index: 1000;
}

.modal-content {
    background: white;
    padding: 2rem;
    border-radius: var(--border-radius);
    max-width: 500px;
    width: 90%;
    position: relative;
    transform: scale(0.7);
    transition: var(--transition);
}

.modal-toggle:checked ~ .modal-overlay {
    opacity: 1;
    visibility: visible;
}

.modal-toggle:checked ~ .modal-overlay .modal-content {
    transform: scale(1);
}

.modal-close {
    position: absolute;
    top: 1rem;
    right: 1rem;
    font-size: 2rem;
    cursor: pointer;
    color: var(--text-light);
    line-height: 1;
}
```

**💡 Key Points:**
- Pure CSS modal without JavaScript
- Smooth scale and fade animations
- Proper z-index layering
- Accessible keyboard interaction

---

## 🌟 Real-World Project Example

### Example 7: Complete Landing Page Component
```html
<section class="pricing-section">
    <div class="container">
        <div class="section-header">
            <h2 class="section-title">Choose Your Plan</h2>
            <p class="section-subtitle">Select the perfect plan for your needs</p>
        </div>
        
        <div class="pricing-grid">
            <div class="pricing-card">
                <div class="card-header">
                    <h3 class="plan-name">Starter</h3>
                    <div class="plan-price">
                        <span class="currency">\$</span>
                        <span class="amount">9</span>
                        <span class="period">/month</span>
                    </div>
                </div>
                <ul class="feature-list">
                    <li class="feature">✓ 5 Projects</li>
                    <li class="feature">✓ 10GB Storage</li>
                    <li class="feature">✓ Email Support</li>
                </ul>
                <button class="plan-button">Get Started</button>
            </div>
            
            <div class="pricing-card featured">
                <div class="popular-badge">Most Popular</div>
                <div class="card-header">
                    <h3 class="plan-name">Professional</h3>
                    <div class="plan-price">
                        <span class="currency">\$</span>
                        <span class="amount">29</span>
                        <span class="period">/month</span>
                    </div>
                </div>
                <ul class="feature-list">
                    <li class="feature">✓ Unlimited Projects</li>
                    <li class="feature">✓ 100GB Storage</li>
                    <li class="feature">✓ Priority Support</li>
                    <li class="feature">✓ Advanced Analytics</li>
                </ul>
                <button class="plan-button primary">Get Started</button>
            </div>
            
            <div class="pricing-card">
                <div class="card-header">
                    <h3 class="plan-name">Enterprise</h3>
                    <div class="plan-price">
                        <span class="currency">\$</span>
                        <span class="amount">99</span>
                        <span class="period">/month</span>
                    </div>
                </div>
                <ul class="feature-list">
                    <li class="feature">✓ Everything in Pro</li>
                    <li class="feature">✓ Unlimited Storage</li>
                    <li class="feature">✓ 24/7 Phone Support</li>
                    <li class="feature">✓ Custom Integrations</li>
                </ul>
                <button class="plan-button">Contact Sales</button>
            </div>
        </div>
    </div>
</section>
```

```css
.pricing-section {
    padding: 5rem 0;
    background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
}

.section-header {
    text-align: center;
    margin-bottom: 3rem;
}

.section-title {
    font-size: 2.5rem;
    font-weight: 700;
    color: var(--text-dark);
    margin-bottom: 1rem;
}

.pricing-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 2rem;
    max-width: 1000px;
    margin: 0 auto;
}

.pricing-card {
    background: white;
    border-radius: 12px;
    padding: 2rem;
    text-align: center;
    position: relative;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
    transition: var(--transition);
}

.pricing-card:hover {
    transform: translateY(-10px);
    box-shadow: 0 8px 30px rgba(0, 0, 0, 0.15);
}

.pricing-card.featured {
    border: 3px solid var(--primary-color);
    transform: scale(1.05);
}

.popular-badge {
    position: absolute;
    top: -12px;
    left: 50%;
    transform: translateX(-50%);
    background: var(--primary-color);
    color: white;
    padding: 0.5rem 1rem;
    border-radius: 20px;
    font-size: 0.875rem;
    font-weight: 600;
}

.plan-price {
    display: flex;
    justify-content: center;
    align-items: baseline;
    margin: 1rem 0 2rem;
}

.amount {
    font-size: 3rem;
    font-weight: 700;
    color: var(--primary-color);
}

.feature-list {
    list-style: none;
    padding: 0;
    margin: 2rem 0;
}

.feature {
    padding: 0.5rem 0;
    color: var(--text-dark);
}

.plan-button {
    width: 100%;
    padding: 1rem;
    border: 2px solid var(--primary-color);
    background: transparent;
    color: var(--primary-color);
    border-radius: var(--border-radius);
    font-weight: 600;
    cursor: pointer;
    transition: var(--transition);
}

.plan-button.primary {
    background: var(--primary-color);
    color: white;
}

.plan-button:hover {
    background: var(--primary-color);
    color: white;
    transform: translateY(-2px);
}
```

**💡 Key Points:**
- Complete responsive pricing section
- Featured card highlighting technique
- Smooth hover animations and transforms
- Professional color scheme and spacing
- Grid layout with auto-fit columns

---

## 🎯 Practice Challenges

Try building these components yourself:

1. **Navigation Bar**: Create a responsive navigation with dropdown menus
2. **Image Gallery**: Build a masonry-style photo grid with lightbox effect
3. **Contact Form**: Design a multi-step form with validation styling
4. **Dashboard Cards**: Create a set of animated statistics cards
5. **Timeline Component**: Build a vertical timeline with alternating content

**Remember**: Practice makes perfect! Start with these examples and modify them to create your own unique designs.''';

      case 'videos':
        return '''## Video Recommendations: HTML and CSS

### Recommended YouTube Searches:
1. "HTML and CSS tutorial for beginners"
2. "Web development HTML CSS basics"
3. "Responsive web design tutorial"
4. "CSS flexbox and grid layout"
5. "HTML semantic elements explained"

### Popular Channels to Check:
• **freeCodeCamp** - Complete HTML/CSS courses
• **Traversy Media** - Practical web development tutorials
• **The Net Ninja** - Step-by-step HTML/CSS series
• **Kevin Powell** - CSS specialist with advanced techniques
• **Web Dev Simplified** - Clear explanations of web concepts''';

      case 'exercises':
        return '''# 🏋️ HTML & CSS Practical Exercises

## 📚 Exercise Categories
1. [Beginner Challenges](#beginner)
2. [Intermediate Projects](#intermediate)
3. [Advanced Applications](#advanced)
4. [Real-World Scenarios](#real-world)

---

## 🌱 Beginner Challenges

### Exercise 1: Personal Profile Card
**Objective**: Create a responsive profile card component

**Requirements**:
- Profile image with circular crop
- Name, title, and brief bio
- Social media links with hover effects
- Contact button with CSS animation
- Mobile-responsive layout

**Skills Practiced**:
- Basic HTML structure
- CSS positioning and layout
- Hover effects and transitions
- Responsive design principles

**Time Estimate**: 2-3 hours

**Starter Code**:
```html
<div class="profile-card">
    <div class="profile-image">
        <img src="avatar.jpg" alt="Profile Photo">
    </div>
    <div class="profile-info">
        <h2 class="name">Your Name</h2>
        <p class="title">Your Title</p>
        <p class="bio">Brief description about yourself</p>
        <div class="social-links">
            <!-- Add social media links -->
        </div>
        <button class="contact-btn">Contact Me</button>
    </div>
</div>
```

**Success Criteria**:
- [ ] Card has proper shadow and border radius
- [ ] Image is perfectly circular
- [ ] Hover effects work smoothly
- [ ] Layout adapts to different screen sizes
- [ ] All text is readable and well-spaced

### Exercise 2: Navigation Menu System
**Objective**: Build a multi-level responsive navigation

**Requirements**:
- Logo/brand area
- Horizontal menu items
- Dropdown submenus
- Mobile hamburger menu
- Smooth animations
- Active state indicators

**Skills Practiced**:
- CSS positioning (absolute/relative)
- Flexbox layout
- CSS transitions
- Mobile-first responsive design
- JavaScript-free interactions

**Bonus Challenges**:
- Add breadcrumb navigation
- Implement mega menu with images
- Create vertical sidebar variation

### Exercise 3: CSS Grid Photo Gallery
**Objective**: Create a responsive image gallery using CSS Grid

**Requirements**:
- Masonry-style layout
- Image hover overlays with information
- Lightbox effect (CSS-only)
- Category filtering with CSS
- Lazy loading indicators

**Skills Practiced**:
- CSS Grid advanced techniques
- Image handling and optimization
- CSS-only modal creation
- Performance considerations

---

## 🚀 Intermediate Projects

### Exercise 4: Landing Page with Sections
**Objective**: Build a complete single-page website

**Sections Required**:
1. **Hero Section**: Full-height with background video/image
2. **About Section**: Two-column layout with images
3. **Services Section**: Card-based grid layout
4. **Portfolio Section**: Filterable project showcase
5. **Testimonials**: Carousel-style reviews
6. **Contact Section**: Working contact form
7. **Footer**: Multi-column with social links

**Advanced Features**:
- Parallax scrolling effects
- Smooth scroll navigation
- Loading animations
- Progressive image enhancement
- SEO optimization

**Time Estimate**: 8-12 hours

### Exercise 5: Dashboard Interface
**Objective**: Create a data dashboard with charts and widgets

**Components**:
- Sidebar navigation with collapse
- Top header with user profile
- Widget grid with different chart types
- Data tables with sorting indicators
- Modal dialogs for settings
- Dark/light theme toggle

**Skills Practiced**:
- Complex CSS layouts
- CSS custom properties for theming
- Component-based thinking
- Data visualization with CSS
- State management with CSS

### Exercise 6: E-commerce Product Page
**Objective**: Build a complete product detail page

**Features**:
- Product image gallery with zoom
- Variant selection (size, color)
- Quantity selector
- Reviews and ratings display
- Related products section
- Sticky add-to-cart functionality

**Technical Challenges**:
- Image zoom without JavaScript
- Complex form styling
- Mobile-optimized interactions
- Performance optimization

---

## 💼 Advanced Applications

### Exercise 7: CSS Framework Creation
**Objective**: Build your own CSS utility framework

**Framework Components**:
- Typography system with consistent scale
- Color palette with CSS custom properties
- Spacing utilities (margin/padding classes)
- Grid system for layouts
- Component library (buttons, cards, forms)
- Utility classes for common patterns

**Documentation Requirements**:
- Style guide with examples
- Usage instructions
- Performance metrics
- Browser compatibility matrix

**Skills Practiced**:
- CSS architecture and organization
- Naming conventions (BEM, SMACSS)
- Build processes and optimization
- Documentation and examples

### Exercise 8: Animated Portfolio Showcase
**Objective**: Create an interactive portfolio with advanced animations

**Animation Requirements**:
- Loading sequence with SVG animations
- Scroll-triggered animations
- Hover effects with transforms
- Page transition effects
- Interactive element reveals

**Technical Implementation**:
- CSS animations and keyframes
- SVG path animations
- Intersection Observer patterns
- Performance optimization for animations

### Exercise 9: Responsive Email Template
**Objective**: Design HTML email that works across all clients

**Challenges**:
- Table-based layout for compatibility
- Inline CSS requirements
- Image fallbacks and alt text
- Dark mode support
- Outlook-specific CSS hacks

**Testing Requirements**:
- Gmail, Outlook, Apple Mail compatibility
- Mobile email client optimization
- Plain text fallback version
- Accessibility compliance

---

## 🌍 Real-World Scenarios

### Scenario 1: Website Redesign Project
**Context**: Modernize an existing website while maintaining brand identity

**Constraints**:
- Must support Internet Explorer 11
- Cannot break existing URLs
- Must improve loading speed by 50%
- Accessibility compliance required
- Budget allows only CSS/HTML changes

**Deliverables**:
- Performance audit report
- Accessibility compliance checklist
- Cross-browser testing results
- Mobile optimization strategy

### Scenario 2: Multi-Brand Design System
**Context**: Create unified design system for multiple brands

**Requirements**:
- Shared components with brand customization
- Consistent spacing and typography
- Theme switching capabilities
- Component documentation
- Implementation guidelines

**Challenge Areas**:
- CSS architecture planning
- Scalable naming conventions
- Version control strategies
- Team collaboration workflows

### Scenario 3: International Website Localization
**Context**: Adapt existing site for multiple languages and regions

**Technical Challenges**:
- Right-to-left (RTL) language support
- Variable text length handling
- Cultural color considerations
- Currency and date formatting
- Font loading for different scripts

**Implementation Strategy**:
- CSS logical properties usage
- Flexible layout systems
- Font stacking strategies
- Performance across regions

---

## 🎯 Assessment Rubric

### Code Quality (25 points)
- **Clean, semantic HTML structure** (5 pts)
- **Organized, maintainable CSS** (5 pts)
- **Proper commenting and documentation** (5 pts)
- **Consistent naming conventions** (5 pts)
- **Cross-browser compatibility** (5 pts)

### Design & UX (25 points)
- **Visual hierarchy and typography** (5 pts)
- **Color scheme and branding** (5 pts)
- **Layout and spacing** (5 pts)
- **Interactive elements and feedback** (5 pts)
- **Overall aesthetic appeal** (5 pts)

### Responsive Design (25 points)
- **Mobile-first approach** (5 pts)
- **Flexible layouts** (5 pts)
- **Appropriate breakpoints** (5 pts)
- **Touch-friendly interactions** (5 pts)
- **Performance on mobile** (5 pts)

### Technical Implementation (25 points)
- **Modern CSS features usage** (5 pts)
- **Performance optimization** (5 pts)
- **Accessibility compliance** (5 pts)
- **SEO best practices** (5 pts)
- **Code validation** (5 pts)

---

## 📝 Submission Guidelines

### Required Deliverables
1. **Source Code**: Well-organized HTML and CSS files
2. **Live Demo**: Working version hosted online (GitHub Pages, Netlify, etc.)
3. **Documentation**: README with setup instructions and design decisions
4. **Self-Assessment**: Reflection on challenges and learning outcomes

### Recommended Tools
- **Code Editor**: VS Code with extensions (Live Server, Prettier)
- **Version Control**: Git and GitHub for project tracking
- **Testing**: Browser DevTools, Lighthouse for performance
- **Validation**: W3C HTML/CSS validators
- **Hosting**: GitHub Pages, Netlify, or Vercel for deployment

### Getting Help
- Use browser DevTools for debugging
- Validate HTML and CSS regularly
- Test on multiple devices and browsers
- Join coding communities for peer feedback
- Document problems and solutions for learning

**Remember**: The goal is learning through practice. Don't be afraid to experiment and make mistakes - that's how you grow as a developer!''';

      default:
        return 'Content for HTML and CSS Foundations will be available soon!';
    }
  }

  String _getDataPreprocessingContent(String promptType) {
    switch (promptType) {
      case 'content':
        return '''# Data Preprocessing: The Foundation of Machine Learning

Welcome to this comprehensive module on **Data Preprocessing**. Data preprocessing is the cornerstone of successful machine learning projects, often determining the difference between accurate and unreliable models.

## 1. What is Data Preprocessing?

### Definition and Core Concepts
**Data Preprocessing** is the systematic process of cleaning, transforming, and preparing raw data for use in machine learning algorithms and data analysis. It involves converting raw, messy, and incomplete data into a clean, consistent, and structured format that machine learning models can effectively process.

The process encompasses multiple stages of data manipulation, including data cleaning, integration, transformation, reduction, and discretization. Each stage addresses specific data quality issues and prepares the dataset for optimal model performance.

### The Data Science Pipeline Context
Data preprocessing typically consumes **60-80% of the total time** in any data science project. This substantial investment is crucial because machine learning algorithms are highly sensitive to data quality, and poor preprocessing can lead to:

- **Garbage In, Garbage Out (GIGO)**: Poor quality input data produces unreliable results
- **Model Bias**: Inconsistent or skewed data creates biased predictions
- **Reduced Accuracy**: Incomplete or noisy data significantly impacts model performance
- **Computational Inefficiency**: Unprocessed data increases training time and resource consumption

### Key Characteristics of Quality Data
- **Accuracy**: Data correctly represents real-world values
- **Completeness**: All required information is present without missing values
- **Consistency**: Data follows uniform formats and standards across the dataset
- **Relevance**: Information is pertinent to the problem being solved
- **Timeliness**: Data is current and reflects the appropriate time period
- **Validity**: Data conforms to defined business rules and constraints

## 2. Importance and Impact of Data Preprocessing

### Critical Role in Machine Learning Success

#### Model Performance Enhancement
Proper data preprocessing can improve model accuracy by **15-25%** on average. Clean, well-structured data allows algorithms to identify genuine patterns rather than being misled by data artifacts, outliers, or inconsistencies.

#### Bias Reduction and Fairness
Preprocessing helps identify and mitigate various types of bias:
- **Selection Bias**: Ensuring representative sampling across all population segments
- **Measurement Bias**: Standardizing data collection methods and instruments
- **Confirmation Bias**: Removing preconceptions that might influence data interpretation
- **Historical Bias**: Addressing past discriminatory practices reflected in legacy data

#### Computational Efficiency
Well-preprocessed data significantly reduces:
- **Training Time**: Clean data requires fewer iterations to converge
- **Memory Usage**: Optimized data structures and reduced dimensionality
- **Processing Power**: Efficient algorithms can focus on pattern recognition rather than error handling

#### Business Impact
Quality preprocessing translates to tangible business benefits:
- **Cost Reduction**: Fewer failed projects and reduced computational expenses
- **Risk Mitigation**: More reliable predictions reduce business uncertainty
- **Competitive Advantage**: Better insights lead to superior decision-making
- **Regulatory Compliance**: Clean data helps meet industry standards and legal requirements

### Real-World Consequences of Poor Preprocessing
- **Financial Losses**: Inaccurate credit scoring models can result in millions in bad loans
- **Safety Risks**: Poorly preprocessed sensor data in autonomous vehicles can cause accidents
- **Legal Issues**: Biased hiring algorithms can lead to discrimination lawsuits
- **Reputation Damage**: Incorrect recommendations or predictions harm brand credibility

## 3. Types of Data Quality Issues

### Missing Data Problems

#### Complete Case Analysis (Listwise Deletion)
**Description**: Removing all records that contain any missing values
**When to Use**: When missing data is less than 5% and occurs completely at random
**Advantages**: Simple implementation, maintains data integrity for complete cases
**Disadvantages**: Significant data loss, potential bias if missingness is not random

#### Pairwise Deletion
**Description**: Using all available data for each analysis, excluding missing values on a case-by-case basis
**When to Use**: When different analyses require different variables
**Advantages**: Maximizes data utilization for each specific analysis
**Disadvantages**: Inconsistent sample sizes across analyses, complex interpretation

#### Imputation Techniques
- **Mean/Median/Mode Imputation**: Replace missing values with central tendency measures
- **Forward/Backward Fill**: Use adjacent values in time series data
- **Linear Interpolation**: Estimate values based on surrounding data points
- **Multiple Imputation**: Generate several plausible values and analyze across all sets
- **Machine Learning Imputation**: Use algorithms like KNN or regression to predict missing values

### Outlier Detection and Treatment

#### Statistical Methods
- **Z-Score Analysis**: Identifies values more than 2-3 standard deviations from the mean
- **Interquartile Range (IQR)**: Flags values below Q1-1.5×IQR or above Q3+1.5×IQR
- **Modified Z-Score**: Uses median absolute deviation for more robust outlier detection
- **Grubbs' Test**: Formally tests for outliers in normally distributed data

#### Machine Learning Approaches
- **Isolation Forest**: Uses ensemble of decision trees to isolate anomalies
- **Local Outlier Factor (LOF)**: Measures local density deviation of data points
- **One-Class SVM**: Learns normal data patterns to identify outliers
- **DBSCAN**: Density-based clustering that naturally identifies outliers as noise

#### Treatment Strategies
- **Removal**: Delete outliers when they represent data entry errors or irrelevant cases
- **Transformation**: Apply log, square root, or other mathematical transformations
- **Winsorization**: Replace extreme values with less extreme percentile values
- **Binning**: Convert continuous variables into categorical ranges
- **Separate Modeling**: Create different models for different data segments

### Data Inconsistency Issues

#### Format Standardization
- **Date Formats**: Converting various date representations (MM/DD/YYYY, DD-MM-YYYY, etc.) to a standard format
- **Text Casing**: Standardizing uppercase, lowercase, and mixed case entries
- **Numerical Formats**: Handling different decimal separators, currency symbols, and measurement units
- **Categorical Labels**: Unifying similar categories (e.g., "USA", "United States", "US")

#### Duplicate Detection and Resolution
- **Exact Duplicates**: Identical records across all fields
- **Near Duplicates**: Records with minor differences due to typos or format variations
- **Fuzzy Matching**: Using string similarity algorithms (Levenshtein distance, Jaccard similarity)
- **Record Linkage**: Connecting related records across different data sources

### Data Integration Challenges

#### Schema Integration
- **Structural Conflicts**: Different attribute names for the same concept
- **Data Type Conflicts**: Varying data types for equivalent information
- **Scale Conflicts**: Different measurement units or precision levels
- **Semantic Conflicts**: Different meanings for similar attribute names

#### Entity Resolution
- **Name Variations**: Multiple representations of the same entity
- **Hierarchical Relationships**: Proper handling of parent-child data relationships
- **Temporal Alignment**: Synchronizing data collected at different time intervals
- **Granularity Matching**: Harmonizing different levels of data detail

## 4. Essential Data Preprocessing Techniques

### Data Cleaning Methodologies

#### Systematic Data Auditing
**Comprehensive Data Profile Creation**:
- Statistical summaries for numerical variables (mean, median, standard deviation, range)
- Frequency distributions for categorical variables
- Missing value patterns and percentages
- Data type verification and consistency checks
- Constraint violation identification
- Cross-field validation rules

**Data Quality Assessment Framework**:
- Completeness metrics: Percentage of missing values per field
- Accuracy measures: Validation against known correct values or business rules
- Consistency checks: Cross-field validation and referential integrity
- Uniqueness verification: Duplicate detection and primary key validation
- Validity assessment: Format, range, and domain constraint verification

#### Advanced Cleaning Techniques
**Automated Error Detection**:
- Rule-based validation using domain expertise
- Statistical anomaly detection using control charts
- Pattern recognition for systematic errors
- Temporal consistency checks for time-series data
- Cross-validation against external reference datasets

### Feature Engineering and Selection

#### Feature Creation Strategies
**Derived Variables**:
- Mathematical transformations (logarithmic, polynomial, trigonometric)
- Ratio and percentage calculations
- Aggregated measures (sums, averages, counts over time periods)
- Interaction terms between existing variables
- Domain-specific calculated fields

**Time-Based Features**:
- Cyclical encoding (day of week, month, season)
- Lag variables for time series analysis
- Rolling window statistics (moving averages, standard deviations)
- Trend and seasonality components
- Time since last event calculations

#### Dimensionality Reduction Methods
**Principal Component Analysis (PCA)**:
- Linear transformation to uncorrelated components
- Variance maximization for optimal information retention
- Eigenvalue analysis for component selection
- Application to high-dimensional datasets

**Feature Selection Techniques**:
- Filter Methods: Correlation analysis, mutual information, chi-square tests
- Wrapper Methods: Forward/backward selection, recursive feature elimination
- Embedded Methods: LASSO regularization, tree-based feature importance
- Hybrid Approaches: Combining multiple selection strategies

### Data Transformation Techniques

#### Normalization and Standardization
**Min-Max Scaling (Normalization)**:
- Formula: (X - X_min) / (X_max - X_min)
- Scales data to [0,1] range
- Preserves original distribution shape
- Sensitive to outliers

**Z-Score Standardization**:
- Formula: (X - μ) / σ
- Centers data around zero with unit variance
- Assumes normal distribution
- Less sensitive to outliers than min-max scaling

**Robust Scaling**:
- Uses median and interquartile range
- Formula: (X - median) / IQR
- Highly resistant to outliers
- Suitable for skewed distributions

#### Advanced Transformation Methods
**Power Transformations**:
- Box-Cox transformation for normality
- Yeo-Johnson transformation (handles negative values)
- Square root and logarithmic transformations
- Inverse and reciprocal transformations

**Distribution Transformation**:
- Quantile transformation (uniform and normal targets)
- Rank-based transformations
- Probability integral transformation
- Copula-based transformations

### Categorical Data Processing

#### Encoding Strategies
**One-Hot Encoding**:
- Creates binary variables for each category
- Suitable for nominal data with few categories
- Avoids ordinal assumptions
- Can lead to high dimensionality

**Ordinal Encoding**:
- Assigns integer values to categories
- Appropriate when natural ordering exists
- Maintains ordinality information
- Risk of implying incorrect relationships

**Target Encoding (Mean Encoding)**:
- Replaces categories with target variable statistics
- Useful for high-cardinality categorical variables
- Risk of overfitting and data leakage
- Requires careful cross-validation implementation

**Advanced Categorical Techniques**:
- Binary encoding for high-cardinality variables
- Hashing encoding for memory efficiency
- Embedding layers for neural networks
- Frequency-based encoding
- Leave-one-out encoding

## 5. Data Preprocessing Workflow and Best Practices

### Systematic Preprocessing Pipeline

#### Phase 1: Data Understanding and Exploration
**Initial Data Assessment**:
1. Load and inspect dataset structure and size
2. Examine data types and identify potential issues
3. Calculate basic statistics and distributions
4. Identify missing value patterns
5. Detect obvious outliers and anomalies
6. Understand business context and domain constraints

**Exploratory Data Analysis (EDA)**:
1. Univariate analysis: Distribution plots, summary statistics
2. Bivariate analysis: Correlation matrices, scatter plots
3. Multivariate analysis: Heatmaps, pair plots
4. Temporal analysis: Time series plots, seasonal patterns
5. Categorical analysis: Bar charts, frequency tables

#### Phase 2: Data Quality Assessment
**Comprehensive Quality Audit**:
1. Missing value analysis and pattern identification
2. Outlier detection using multiple methods
3. Duplicate identification and assessment
4. Consistency checking across related fields
5. Validity verification against business rules
6. Completeness assessment for critical variables

**Documentation and Tracking**:
1. Record all identified data quality issues
2. Document business rules and constraints
3. Track data lineage and transformation history
4. Maintain version control for preprocessing steps
5. Create data quality reports and dashboards

#### Phase 3: Strategic Cleaning and Transformation
**Prioritized Issue Resolution**:
1. Address critical data quality issues first
2. Handle missing values using appropriate strategies
3. Treat outliers based on domain knowledge
4. Resolve duplicates and inconsistencies
5. Standardize formats and encodings
6. Validate transformations against business logic

**Feature Engineering Excellence**:
1. Create meaningful derived variables
2. Apply domain-specific transformations
3. Engineer interaction and polynomial features
4. Implement time-based feature extraction
5. Perform feature selection and dimensionality reduction
6. Validate feature quality and relevance

### Quality Assurance and Validation

#### Preprocessing Validation Framework
**Cross-Validation Integration**:
- Separate preprocessing pipeline for training and testing data
- Prevent data leakage through proper temporal splits
- Validate preprocessing decisions using holdout datasets
- Implement nested cross-validation for hyperparameter tuning

**Statistical Validation**:
- Compare distributions before and after preprocessing
- Verify that transformations achieve intended objectives
- Check for introduction of new biases or artifacts
- Validate preservation of important relationships

**Business Logic Validation**:
- Ensure preprocessing aligns with domain expertise
- Verify that transformations maintain business meaning
- Check compliance with regulatory requirements
- Validate interpretability of processed features

#### Documentation and Reproducibility
**Comprehensive Documentation**:
- Document all preprocessing decisions and rationale
- Record parameter values and configuration settings
- Maintain clear code comments and explanations
- Create preprocessing methodology reports

**Reproducibility Standards**:
- Version control for all preprocessing code
- Seed random number generators for consistent results
- Create containerized environments for deployment
- Implement automated testing for preprocessing pipelines

### Advanced Preprocessing Considerations

#### Handling Temporal Data
**Time Series Preprocessing**:
- Handle irregular time intervals and missing timestamps
- Implement proper temporal train/test splits
- Create lag features and rolling window statistics
- Address seasonality and trend components
- Handle multiple time series alignment

#### Big Data Preprocessing
**Scalable Processing Strategies**:
- Implement distributed preprocessing using frameworks like Spark
- Use streaming processing for real-time data preparation
- Optimize memory usage through chunked processing
- Implement parallel processing for computationally intensive operations
- Use efficient data formats (Parquet, HDF5) for large datasets

#### Domain-Specific Preprocessing
**Industry Applications**:
- Financial data: Currency normalization, regulatory compliance
- Healthcare: HIPAA compliance, medical coding standardization
- E-commerce: Customer behavior analysis, seasonality handling
- Manufacturing: Sensor data calibration, quality control metrics
- Social media: Text preprocessing, sentiment normalization

This comprehensive approach to data preprocessing ensures that your machine learning projects start with the highest quality data foundation, leading to more accurate, reliable, and actionable insights.''';

      case 'examples':
        return '''# Data Preprocessing Examples

## Example 1: Handling Missing Values

### Problem Scenario
A customer dataset with 10,000 records contains missing values in the income field (15% missing) and age field (8% missing).

### Solution Approaches

#### Method 1: Statistical Imputation
```python
# Mean imputation for income
df['income'].fillna(df['income'].mean(), inplace=True)

# Median imputation for age (more robust to outliers)
df['age'].fillna(df['age'].median(), inplace=True)
```

#### Method 2: Advanced Imputation
```python
from sklearn.impute import KNNImputer
from sklearn.experimental import enable_iterative_imputer
from sklearn.impute import IterativeImputer

# KNN Imputation
knn_imputer = KNNImputer(n_neighbors=5)
df_knn = pd.DataFrame(knn_imputer.fit_transform(df[['age', 'income']]))

# Multiple Imputation
iter_imputer = IterativeImputer(max_iter=10, random_state=42)
df_iter = pd.DataFrame(iter_imputer.fit_transform(df[['age', 'income']]))
```

### Impact Analysis
- Simple mean imputation: 12% improvement in model accuracy
- KNN imputation: 18% improvement in model accuracy
- Multiple imputation: 22% improvement with reduced bias

## Example 2: Outlier Detection and Treatment

### Problem Scenario
Sales data contains extreme values that could be either legitimate high-value transactions or data entry errors.

### Detection Methods
```python
# Statistical outlier detection
Q1 = df['sales'].quantile(0.25)
Q3 = df['sales'].quantile(0.75)
IQR = Q3 - Q1
outliers = df[(df['sales'] < Q1 - 1.5*IQR) | (df['sales'] > Q3 + 1.5*IQR)]

# Z-score method
from scipy import stats
z_scores = np.abs(stats.zscore(df['sales']))
outliers_zscore = df[z_scores > 3]
```

### Treatment Strategy
```python
# Winsorization approach
from scipy.stats.mstats import winsorize
df['sales_winsorized'] = winsorize(df['sales'], limits=[0.05, 0.05])

# Transformation approach
df['sales_log'] = np.log1p(df['sales'])  # log(1+x) to handle zeros
```

## Example 3: Feature Engineering

### Creating Derived Features
```python
# Date-based features
df['transaction_date'] = pd.to_datetime(df['transaction_date'])
df['day_of_week'] = df['transaction_date'].dt.dayofweek
df['month'] = df['transaction_date'].dt.month
df['is_weekend'] = df['day_of_week'].isin([5, 6]).astype(int)

# Customer behavior features
df['avg_transaction_amount'] = df.groupby('customer_id')['amount'].transform('mean')
df['transaction_frequency'] = df.groupby('customer_id')['transaction_id'].transform('count')
df['days_since_last_transaction'] = df.groupby('customer_id')['transaction_date'].diff().dt.days
```

### Categorical Encoding Example
```python
# One-hot encoding for low cardinality
pd.get_dummies(df['product_category'], prefix='category')

# Target encoding for high cardinality
category_means = df.groupby('store_location')['sales'].mean()
df['location_avg_sales'] = df['store_location'].map(category_means)
```

## Example 4: Comprehensive Preprocessing Pipeline

### Complete Workflow
```python
from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.impute import SimpleImputer

# Define preprocessing steps
numeric_features = ['age', 'income', 'transaction_amount']
categorical_features = ['product_category', 'customer_segment']

# Numeric pipeline
numeric_pipeline = Pipeline([
    ('imputer', SimpleImputer(strategy='median')),
    ('scaler', StandardScaler())
])

# Categorical pipeline  
categorical_pipeline = Pipeline([
    ('imputer', SimpleImputer(strategy='constant', fill_value='unknown')),
    ('onehot', OneHotEncoder(drop='first', sparse=False))
])

# Combine pipelines
preprocessor = ColumnTransformer([
    ('num', numeric_pipeline, numeric_features),
    ('cat', categorical_pipeline, categorical_features)
])

# Fit and transform
X_processed = preprocessor.fit_transform(X_train)
```

### Results and Impact
- Data quality score improved from 62% to 94%
- Model training time reduced by 35%
- Cross-validation accuracy increased by 28%
- Feature interpretability enhanced significantly''';

      case 'exercises':
        return '''# Data Preprocessing Practical Exercises

## Exercise 1: Customer Data Cleaning Challenge

### Dataset Description
You have a customer database with the following issues:
- Missing values in income (20%), age (12%), and email (8%)
- Duplicate customer records with slight variations
- Inconsistent date formats across different sources
- Outliers in purchase amounts
- Mixed case and formatting in categorical variables

### Tasks to Complete

#### Task 1.1: Missing Value Analysis
1. Analyze missing value patterns across all variables
2. Determine if missing values are Missing Completely at Random (MCAR), Missing at Random (MAR), or Not Missing at Random (NMAR)
3. Create visualizations to show missing value patterns
4. Implement appropriate imputation strategies for each variable

#### Task 1.2: Duplicate Detection
1. Identify exact and near-duplicate records
2. Implement fuzzy matching for customer names and addresses
3. Create a deduplication strategy that preserves data integrity
4. Validate the deduplication results

#### Task 1.3: Data Standardization
1. Standardize date formats across all date fields
2. Clean and standardize categorical variables (product names, categories)
3. Handle text data inconsistencies (case, spacing, special characters)
4. Implement data validation rules

### Expected Outcomes
- Clean dataset with <2% missing values
- Elimination of duplicate records while preserving unique information
- Consistent data formats across all fields
- Documented data quality improvements

## Exercise 2: E-commerce Transaction Processing

### Scenario
An e-commerce company provides transaction data with multiple data quality issues that need preprocessing before building recommendation and forecasting models.

### Challenges to Address

#### Data Quality Issues
- Seasonal transaction patterns with missing holiday data
- Customer behavior changes over time
- Product categorization inconsistencies
- Currency conversion requirements for international transactions
- Fraudulent transaction identification and handling

#### Required Preprocessing Steps

**Step 1: Temporal Data Handling**
1. Create proper time series structure with regular intervals
2. Handle missing time periods and seasonal adjustments
3. Generate time-based features (seasonality, trends, cyclical patterns)
4. Implement appropriate temporal train/test splits

**Step 2: Feature Engineering**
1. Customer lifetime value calculations
2. Product affinity and cross-selling features
3. Seasonal purchasing behavior indicators
4. Geographic and demographic feature creation

**Step 3: Advanced Techniques**
1. Implement outlier detection for fraudulent transactions
2. Create customer segmentation features
3. Handle multi-currency normalization
4. Generate recommendation system features

### Deliverables
- Complete preprocessing pipeline
- Feature engineering documentation
- Data quality assessment report
- Validation of preprocessing effectiveness

## Exercise 3: Healthcare Data Preprocessing

### Medical Dataset Challenges
Working with patient health records requiring careful preprocessing while maintaining privacy and regulatory compliance.

### Key Requirements

#### Privacy and Compliance
1. Implement proper anonymization techniques
2. Handle sensitive information according to HIPAA guidelines
3. Create audit trails for all data transformations
4. Ensure reproducible preprocessing while maintaining privacy

#### Medical Data Specific Issues
1. Handle missing lab values and test results
2. Normalize medical terminology and coding systems
3. Process time-series vital signs data
4. Handle irregular measurement intervals

#### Clinical Feature Engineering
1. Create derived health indicators
2. Generate risk assessment features
3. Handle medication interaction features
4. Process diagnostic code hierarchies

### Success Criteria
- HIPAA-compliant data processing
- Clinical accuracy preservation
- Improved predictive model performance
- Documentation suitable for regulatory review

## Exercise 4: Real-Time Data Preprocessing Pipeline

### Streaming Data Challenge
Design and implement a preprocessing pipeline for real-time sensor data from IoT devices.

### Technical Requirements

#### Stream Processing
1. Handle high-velocity data streams (1000+ records/second)
2. Implement real-time outlier detection and filtering
3. Create sliding window aggregations
4. Handle missing or delayed sensor readings

#### Quality Assurance
1. Implement data drift detection
2. Create automated quality alerts
3. Handle sensor calibration drift
4. Maintain preprocessing performance under load

#### Scalability Considerations
1. Design for horizontal scaling
2. Implement efficient memory management
3. Create monitoring and alerting systems
4. Handle system failures gracefully

### Technical Stack Options
- Apache Kafka + Apache Spark Streaming
- Apache Flink for complex event processing
- AWS Kinesis + Lambda for cloud-native solutions
- Custom Python/asyncio solutions for specific requirements

## Exercise 5: Multi-Source Data Integration

### Complex Integration Scenario
Integrate customer data from multiple sources (CRM, transactions, social media, support tickets) into a unified dataset for machine learning.

### Integration Challenges

#### Schema Harmonization
1. Resolve naming conflicts across data sources
2. Handle different data types for equivalent information
3. Create master data management approach
4. Implement data lineage tracking

#### Entity Resolution
1. Match customers across different systems
2. Handle name variations and aliases
3. Resolve temporal misalignments
4. Create confidence scores for matches

#### Data Quality Reconciliation
1. Handle conflicting information across sources
2. Implement data quality scoring
3. Create master record creation rules
4. Maintain audit trails for decisions

### Advanced Techniques
1. Probabilistic record linkage
2. Machine learning-based entity resolution
3. Graph-based relationship modeling
4. Active learning for uncertain matches

## Assessment Criteria

### Technical Excellence (40%)
- Code quality and organization
- Appropriate technique selection
- Performance optimization
- Error handling and robustness

### Data Quality Improvement (30%)
- Measurable quality improvements
- Appropriate validation methods
- Business rule compliance
- Statistical validation of results

### Documentation and Reproducibility (20%)
- Clear methodology documentation
- Code comments and explanations
- Reproducible results
- Version control practices

### Innovation and Insight (10%)
- Creative problem-solving approaches
- Domain-specific considerations
- Novel technique applications
- Business impact assessment

### Submission Requirements
1. Complete preprocessing code with detailed comments
2. Data quality assessment before and after preprocessing
3. Validation results and statistical tests
4. Performance benchmarks and optimization notes
5. Documentation of business rules and decisions
6. Presentation of results and recommendations''';

      case 'videos':
        return '''# Recommended Video Resources for Data Preprocessing

## Comprehensive Course Series

### **StatQuest with Josh Starmer** - Data Preprocessing Fundamentals
**Duration**: 2-4 hours total across multiple videos
**Level**: Beginner to Intermediate
**Key Topics**: Missing data, normalization, feature selection
**Why Watch**: Excellent visual explanations with simple, clear examples
**Best Videos**:
- "Missing data: what to do with it"
- "StatQuest: Normalizing data"
- "Feature Selection methods"

### **Krish Naik** - Complete Data Preprocessing Series
**Duration**: 6-8 hours comprehensive series
**Level**: Beginner to Advanced
**Key Topics**: End-to-end preprocessing pipeline, real-world examples
**Why Watch**: Practical implementation with Python and real datasets
**Notable Content**:
- "Data Preprocessing End to End Project"
- "Handling Missing Values Complete Tutorial"
- "Feature Engineering Techniques"

### **Data School (Kevin Markham)** - Pandas for Data Preprocessing
**Duration**: 4-6 hours series
**Level**: Intermediate
**Key Topics**: Pandas operations, data cleaning with Python
**Why Watch**: Hands-on coding approach with real datasets
**Must-Watch Videos**:
- "Data Cleaning with Pandas"
- "Handling Missing Data in Pandas"
- "Working with Dates and Times"

## Specialized Topic Videos

### **3Blue1Brown** - Understanding Principal Component Analysis
**Duration**: 20 minutes
**Level**: Intermediate to Advanced
**Focus**: Mathematical intuition behind PCA for dimensionality reduction
**Why Essential**: Beautiful mathematical visualization of complex concepts

### **Two Minute Papers** - Latest Research in Data Processing
**Duration**: 2-3 minutes per video
**Level**: All levels
**Focus**: Cutting-edge research and techniques
**Value**: Stay updated with latest developments in automated preprocessing

### **Sentdex** - Practical Data Processing with Python
**Duration**: 10-30 minutes per video
**Level**: Intermediate
**Focus**: Real-world implementation and debugging
**Strength**: Shows common mistakes and how to fix them

## Industry Expert Talks

### **Cassie Kozyrkov (Google)** - Decision Intelligence and Data Quality
**Duration**: 45-60 minute conference talks
**Level**: All levels
**Focus**: Strategic thinking about data preprocessing decisions
**Key Insight**: When and why certain preprocessing choices matter for business outcomes

### **Hilary Mason** - Data Strategy and Preprocessing Best Practices  
**Duration**: 30-45 minute talks
**Level**: Intermediate to Advanced
**Focus**: Enterprise-scale data preprocessing challenges
**Value**: Real-world case studies from industry experience

## Hands-On Tutorial Channels

### **Corey Schafer** - Python Data Analysis Series
**Duration**: 20-40 minutes per tutorial
**Level**: Beginner to Intermediate
**Strength**: Clear, step-by-step coding tutorials
**Best for**: Learning pandas, numpy, and scikit-learn preprocessing tools

### **DataCamp** - Interactive Data Preprocessing
**Duration**: 15-25 minutes per lesson
**Level**: Beginner
**Format**: Interactive coding exercises with explanations
**Advantage**: Practice while learning with immediate feedback

### **freeCodeCamp** - Complete Data Science Courses
**Duration**: 4-10 hour complete courses
**Level**: Beginner to Advanced
**Coverage**: Comprehensive coverage including preprocessing
**Value**: Free, complete curriculum with projects

## Advanced and Research-Focused Content

### **deeplearning.ai (Andrew Ng)** - Machine Learning Data Preprocessing
**Duration**: 1-2 hours within broader ML courses
**Level**: Intermediate to Advanced
**Focus**: Preprocessing in context of machine learning pipeline
**Authority**: From leading ML researcher and educator

### **Fast.ai** - Practical Deep Learning Preprocessing
**Duration**: Portions of 2-hour lessons
**Level**: Intermediate to Advanced
**Approach**: Top-down practical approach to preprocessing for deep learning
**Unique Value**: Modern techniques and best practices

## Platform-Specific Tutorials

### **Kaggle Learn** - Data Cleaning Course
**Duration**: 4-5 hours
**Level**: Beginner to Intermediate
**Format**: Interactive notebooks with real competition data
**Benefit**: Learn on actual messy datasets from competitions

### **Google Cloud AI** - AutoML and Preprocessing
**Duration**: 30-45 minutes per video
**Level**: Intermediate
**Focus**: Cloud-based preprocessing and automation
**Value**: Industry-standard tools and practices

### **AWS Machine Learning** - Data Preparation Services
**Duration**: 20-40 minutes per tutorial
**Level**: Intermediate to Advanced
**Coverage**: SageMaker Data Wrangler and preprocessing services
**Relevance**: Enterprise-scale data preprocessing solutions

## Project-Based Learning Videos

### **Keith Galli** - Data Science Project Walkthroughs
**Duration**: 1-2 hours per project
**Level**: Intermediate
**Format**: Complete project from raw data to insights
**Strength**: Shows entire preprocessing workflow in real projects

### **Ken Jee** - Data Science Portfolio Projects
**Duration**: 30-60 minutes per project
**Focus**: Building portfolio-worthy projects with proper preprocessing
**Value**: Learn professional-level data preparation techniques

## Quick Reference and Tips

### **Data Professor** - Short Concept Explanations
**Duration**: 10-15 minutes per video
**Level**: Beginner to Intermediate
**Format**: Focused explanations of specific concepts
**Best for**: Quick learning and concept clarification

### **Python Engineer** - Preprocessing Tips and Tricks
**Duration**: 15-30 minutes per video
**Level**: Intermediate
**Content**: Efficient coding techniques and common pitfalls
**Utility**: Practical tips to improve preprocessing workflow efficiency

## Live Coding and Streams

### **Keith Galli Live Streams** - Real-time problem solving
**Duration**: 2-4 hours
**Level**: All levels
**Format**: Live coding with audience interaction
**Learning**: See how experienced practitioners handle unexpected data issues

### **Sentdex Live** - Community data science projects
**Duration**: 1-3 hours
**Community**: Active chat and collaboration
**Benefit**: Learn from community questions and collaborative problem-solving

## Recommended Viewing Path

### Beginner Path (20-25 hours)
1. Start with **StatQuest** fundamentals (4 hours)
2. Follow with **Krish Naik** practical series (8 hours)
3. Practice with **DataCamp** interactive lessons (6 hours)
4. Apply learning with **Kaggle Learn** (5 hours)
5. Watch project walkthroughs by **Keith Galli** (4 hours)

### Intermediate Path (15-20 hours)
1. **Data School** pandas mastery (6 hours)
2. **Corey Schafer** advanced techniques (4 hours)
3. **Cassie Kozyrkov** strategic thinking (2 hours)
4. **deeplearning.ai** ML context (4 hours)
5. **Fast.ai** modern approaches (4 hours)

### Advanced Path (10-15 hours)
1. **3Blue1Brown** mathematical foundations (2 hours)
2. **Hilary Mason** enterprise perspectives (2 hours)
3. **Google Cloud** and **AWS** platform tools (4 hours)
4. **Two Minute Papers** research updates (2 hours)
5. Live streams and community projects (6 hours)

### Tips for Effective Video Learning
- **Take Notes**: Pause frequently to implement concepts
- **Code Along**: Always have your development environment open
- **Practice Immediately**: Apply concepts to your own datasets
- **Join Communities**: Engage with video creators and fellow learners
- **Build Projects**: Use multiple video sources for comprehensive projects

Remember: Video learning is most effective when combined with hands-on practice and real-world application!''';

      default:
        return 'Content for Data Preprocessing will be available soon!';
    }
  }

  String _getMachineLearningContent(String promptType) {
    switch (promptType) {
      case 'content':
        return '''# Machine Learning Fundamentals

## 1. Introduction to Machine Learning
Machine Learning is a powerful subset of artificial intelligence that enables computers to learn and make predictions or decisions without being explicitly programmed for each specific task.

## 2. Types of Machine Learning
- **Supervised Learning**: Learning with labeled examples
- **Unsupervised Learning**: Finding patterns in unlabeled data  
- **Reinforcement Learning**: Learning through interaction and feedback

## 3. Key Concepts
Understanding the fundamental concepts that drive machine learning algorithms and their applications.

## 4. Common Algorithms
Overview of popular machine learning algorithms and their use cases.

## 5. Model Evaluation
Methods for assessing and improving machine learning model performance.''';

      case 'examples':
        return '''# Machine Learning Examples

## Linear Regression Example
A simple supervised learning algorithm for predicting continuous values.

## Classification Example  
Using decision trees to classify data into discrete categories.

## Clustering Example
K-means clustering for grouping similar data points.''';

      case 'exercises':
        return '''# Machine Learning Exercises

## Exercise 1: Build a Prediction Model
Create a simple linear regression model to predict house prices.

## Exercise 2: Classification Challenge
Develop a classifier to distinguish between different types of data.

## Exercise 3: Clustering Analysis
Apply clustering techniques to discover patterns in customer data.''';

      case 'videos':
        return '''# Recommended Machine Learning Videos

## Popular Channels to Check:
• **3Blue1Brown** - Neural Networks series
• **StatQuest with Josh Starmer** - ML concepts explained simply
• **Andrew Ng's Machine Learning Course** - Comprehensive ML education
• **Two Minute Papers** - Latest ML research
• **Sentdex** - Practical ML with Python''';

      default:
        return 'Content for Machine Learning will be available soon!';
    }
  }

  String _getStateManagementContent(String promptType) {
    switch (promptType) {
      case 'content':
        return '''# State Management in Flutter

State management is a critical aspect of building robust and scalable applications in Flutter, as it enables developers to manage the state of their app's widgets efficiently. The state refers to the current condition or status of an object or a system, and in the context of Flutter, it encompasses the data and properties that define the user interface and user experience.

Understanding the fundamental concepts of state management is essential for building apps that are responsive, intuitive, and easy to use. Historically, state management has evolved significantly, from simple, ephemeral state management, where the state is stored locally within a widget, to more complex app state management, where the state is shared across multiple widgets and components.

This evolution has led to the development of various state management libraries, such as Provider and Riverpod, which simplify the process of managing app state.

## 1. Understanding State in Flutter

### What is State?
State represents the data that can change during the lifetime of a widget. In Flutter, state determines what the user interface looks like at any given moment. When state changes, Flutter rebuilds the affected widgets to reflect those changes in the UI.

### Types of State in Flutter

#### Ephemeral State (Widget State)
Ephemeral state is state that can be contained in a single widget. This type of state doesn't need to be shared with other parts of the widget tree and is typically managed using StatefulWidget and setState().

**Characteristics of Ephemeral State:**
- Lives within a single widget
- Short-lived and temporary
- Examples: current page in PageView, animation progress, form field values
- Managed with setState() method
- Automatically disposed when widget is removed

**Common Examples:**
- Selected tab in a TabBar
- Current value of a slider or text field
- Animation controller states
- Loading indicators for specific widgets
- Expanded state of ExpansionTile

#### App State (Shared State)
App state is state that needs to be shared across multiple parts of your app. This includes user preferences, authentication status, shopping cart contents, or any data that multiple widgets need to access.

**Characteristics of App State:**
- Shared across multiple widgets
- Persists beyond individual widget lifecycles
- Examples: user login status, theme preferences, shopping cart items
- Requires specialized state management solutions
- Can be persisted across app sessions

**Common Examples:**
- User authentication status
- Application theme (light/dark mode)
- Shopping cart contents
- User profile information
- Application settings and preferences
- Network connection status

### State Lifecycle in Flutter

#### Widget Lifecycle and State
Understanding the widget lifecycle is crucial for effective state management:

1. **createState()**: Called when StatefulWidget is inserted into the widget tree
2. **initState()**: Called once when the State object is created
3. **didChangeDependencies()**: Called when dependencies of the State object change
4. **build()**: Called whenever the widget needs to be rendered
5. **didUpdateWidget()**: Called when the parent widget changes and needs to update this widget
6. **setState()**: Triggers a rebuild of the widget
7. **deactivate()**: Called when the State object is removed from the tree
8. **dispose()**: Called when the State object is removed permanently

## 2. Built-in State Management Solutions

### StatefulWidget and setState()

#### Basic Implementation
StatefulWidget is the most fundamental way to manage ephemeral state in Flutter. It's perfect for simple, widget-specific state that doesn't need to be shared.

**Key Components:**
- StatefulWidget class that creates the state
- State class that holds the mutable state
- setState() method to trigger rebuilds
- Widget lifecycle methods for initialization and cleanup

**Best Practices:**
- Use for simple, widget-local state only
- Keep state minimal and focused
- Always call setState() when modifying state
- Dispose resources properly in dispose() method
- Avoid heavy computations in build() method

**When to Use setState():**
- Managing form field values
- Handling button press states
- Controlling animation states
- Simple counters or toggles
- Widget-specific UI state

### InheritedWidget

#### Advanced State Sharing
InheritedWidget is a special widget that efficiently propagates data down the widget tree. It's the foundation for many state management solutions and provides a way to share data without explicitly passing it through constructors.

**How InheritedWidget Works:**
- Data flows down the widget tree automatically
- Widgets can access inherited data using BuildContext
- Automatic rebuilds when inherited data changes
- Efficient updates through dependency tracking
- Forms the basis for Provider and other solutions

**Implementation Pattern:**
1. Create a class extending InheritedWidget
2. Implement updateShouldNotify() method
3. Provide static access method
4. Wrap your app or widget subtree
5. Access data using context.dependOnInheritedWidgetOfExactType()

**Advantages:**
- Efficient data propagation
- Automatic dependency tracking
- No need for explicit data passing
- Built into Flutter framework
- Type-safe data access

**Limitations:**
- Complex to implement correctly
- Requires boilerplate code
- No built-in state mutation methods
- Can lead to complex widget trees
- Difficult debugging without proper tools

## 3. Popular State Management Libraries

### Provider Package

#### Overview and Philosophy
Provider is one of the most popular state management solutions for Flutter, recommended by the Flutter team. It's built on top of InheritedWidget but provides a much simpler and more intuitive API.

**Core Concepts:**
- ChangeNotifier for managing state
- Provider widgets for exposing state
- Consumer widgets for reading state
- Selector widgets for optimized rebuilds
- MultiProvider for multiple providers

#### Provider Implementation Patterns

**Basic ChangeNotifier:**
ChangeNotifier is a simple class that provides change notification to its listeners. It's the foundation of the Provider pattern and perfect for managing mutable state.

**Key Features:**
- Simple state management with notifyListeners()
- Automatic disposal of resources
- Memory leak prevention
- Integration with Provider widgets
- Support for multiple listeners

**Provider Types:**
- Provider: For simple, immutable data
- ChangeNotifierProvider: For mutable state with ChangeNotifier
- FutureProvider: For asynchronous data loading
- StreamProvider: For continuous data streams
- ProxyProvider: For providers dependent on other providers

**Consumer Patterns:**
- Consumer: Rebuilds when provider changes
- Selector: Rebuilds only when specific data changes
- Consumer2, Consumer3: Multiple provider consumption
- Provider.of(): Direct access without rebuilding

#### Advanced Provider Techniques

**State Persistence:**
- SharedPreferences integration
- Local database storage
- File system persistence
- Cloud synchronization
- Automatic state restoration

**Performance Optimization:**
- Selector for granular rebuilds
- Provider.of(listen: false) for non-UI logic
- Lazy initialization with lazy parameter
- Dispose pattern for resource cleanup
- Memory usage monitoring

### Riverpod

#### Next-Generation State Management
Riverpod is created by the same author as Provider but addresses many of Provider's limitations. It offers compile-time safety, better testing support, and more flexible architecture.

**Key Improvements over Provider:**
- No dependency on BuildContext
- Compile-time safety and error detection
- Better testing and mocking support
- Automatic disposal and dependency management
- Support for async programming patterns

#### Riverpod Provider Types

**StateProvider:**
- Simple state management for primitive types
- Built-in state mutation methods
- Automatic change notifications
- Type-safe state access
- Perfect for simple app settings

**StateNotifierProvider:**
- Advanced state management with StateNotifier
- Immutable state with controlled mutations
- Complex state logic encapsulation
- Excellent for business logic
- Support for state history and debugging

**FutureProvider and StreamProvider:**
- Async data handling with built-in loading states
- Error handling and retry mechanisms
- Automatic dependency management
- Clean async programming patterns
- Integration with network requests

#### Riverpod Architecture Benefits

**Dependency Injection:**
- Clean separation of concerns
- Testable business logic
- Mockable dependencies
- Flexible provider composition
- Runtime dependency resolution

**Performance Features:**
- Automatic dependency tracking
- Intelligent rebuilds and caching
- Lazy loading and initialization
- Memory leak prevention
- Efficient state updates

### BLoC (Business Logic Components)

#### Pattern Overview
BLoC is an architectural pattern that separates business logic from UI components using streams and reactive programming. It promotes clean architecture and testable code.

**Core Principles:**
- Separation of business logic from UI
- Reactive programming with streams
- Predictable state changes
- Easy testing and debugging
- Platform independence

#### BLoC Components

**Events:**
- User interactions and system events
- Immutable data classes
- Trigger state changes
- Clear intent communication
- Type-safe event handling

**States:**
- Represent current application state
- Immutable data structures
- UI rebuilds based on state changes
- Clear state representations
- Easy state testing

**BLoC Class:**
- Maps events to states
- Contains business logic
- Manages state transitions
- Handles async operations
- Provides stream of states

## 4. Choosing the Right State Management Solution

### Decision Framework

#### Project Complexity Assessment
**Simple Apps (Local State Focus):**
- Use StatefulWidget and setState()
- Minimal state sharing requirements
- Short development timeline
- Small team or solo development
- Learning Flutter fundamentals

**Medium Complexity Apps:**
- Provider for straightforward state sharing
- Moderate amount of shared state
- Team familiar with Flutter patterns
- Need for quick development
- Standard business applications

**Complex Apps (Enterprise Level):**
- BLoC for complex business logic
- Riverpod for type safety and testing
- Large development teams
- Complex state relationships
- Long-term maintenance requirements
- High performance needs

#### Technical Considerations

**Performance Requirements:**
- Frequent state updates: Consider Riverpod or BLoC
- Large widget trees: Use Selector or specialized consumers
- Memory constraints: Provider with proper disposal
- Animation-heavy apps: Local state with setState()
- Real-time data: StreamProvider or BLoC

**Team and Maintenance:**
- Team experience level
- Code review and quality standards
- Testing requirements and coverage
- Documentation needs
- Future scalability plans
- Learning curve considerations

## 5. Best Practices and Common Patterns

### State Management Best Practices

#### Architecture Guidelines
**Separation of Concerns:**
- Keep business logic separate from UI logic
- Use dedicated classes for state management
- Avoid mixing state management approaches
- Create clear boundaries between layers
- Document state flow and dependencies

**State Immutability:**
- Prefer immutable state objects
- Use copyWith() methods for updates
- Avoid direct state mutations
- Implement proper equality operators
- Use freezed package for data classes

**Error Handling:**
- Implement comprehensive error states
- Provide meaningful error messages
- Handle network failures gracefully
- Include retry mechanisms
- Log errors for debugging

#### Performance Optimization

**Rebuild Optimization:**
- Use Selector for granular updates
- Implement shouldRebuild logic
- Avoid unnecessary state changes
- Cache expensive computations
- Monitor widget rebuild frequency

**Memory Management:**
- Properly dispose resources
- Avoid memory leaks in listeners
- Use weak references where appropriate
- Monitor memory usage patterns
- Implement proper lifecycle management

### Common Anti-Patterns to Avoid

**Overcomplicating Simple State:**
- Using complex solutions for simple problems
- Premature optimization of state management
- Creating unnecessary abstractions
- Mixing multiple state management approaches
- Ignoring Flutter's built-in solutions

**State Management Mistakes:**
- Forgetting to dispose resources
- Creating circular dependencies
- Excessive state sharing
- Poor error handling
- Inadequate testing coverage

This comprehensive understanding of state management in Flutter will help you build more maintainable, performant, and scalable applications. The key is to start simple and evolve your state management approach as your application's complexity grows.''';

      case 'examples':
        return '''# State Management Examples

## Example 1: Simple Counter with setState()

### Basic StatefulWidget Implementation
```dart
class CounterWidget extends StatefulWidget {
  @override
  _CounterWidgetState createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Counter App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('You have pushed the button this many times:'),
            Text('\$_counter', style: Theme.of(context).textTheme.headline4),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
```

## Example 2: Shopping Cart with Provider

### Model Class
```dart
class CartItem {
  final String id;
  final String name;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
  });
}

class Cart with ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  double get totalPrice => _items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  void addItem(CartItem item) {
    final existingIndex = _items.indexWhere((element) => element.id == item.id);
    
    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void updateQuantity(String id, int quantity) {
    final item = _items.firstWhere((item) => item.id == id);
    item.quantity = quantity;
    if (quantity <= 0) {
      removeItem(id);
    } else {
      notifyListeners();
    }
  }
}
```

### Provider Setup
```dart
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => Cart(),
      child: MyApp(),
    ),
  );
}
```

### Consumer Widget
```dart
class CartSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Cart>(
      builder: (context, cart, child) {
        return Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cart Summary', style: Theme.of(context).textTheme.headline6),
                SizedBox(height: 8),
                Text('Items: \${cart.itemCount}'),
                Text('Total: \\\$\${cart.totalPrice.toStringAsFixed(2)}'),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

## Example 3: User Authentication with Riverpod

### State Notifier Implementation
```dart
class User {
  final String id;
  final String email;
  final String name;

  const User({
    required this.id,
    required this.email,
    required this.name,
  });
}

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 2));
      
      if (email == 'user@example.com' && password == 'password') {
        final user = User(
          id: '1',
          email: email,
          name: 'John Doe',
        );
        state = state.copyWith(user: user, isLoading: false);
      } else {
        state = state.copyWith(
          error: 'Invalid credentials',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Login failed: \$e',
        isLoading: false,
      );
    }
  }

  void logout() {
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
```

### Consumer Widget with Riverpod
```dart
class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            if (authState.isLoading)
              CircularProgressIndicator()
            else ...[
              TextField(
                decoration: InputDecoration(labelText: 'Email'),
                onChanged: (value) => email = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                onChanged: (value) => password = value,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => authNotifier.login(email, password),
                child: Text('Login'),
              ),
            ],
            if (authState.error != null)
              Text(
                authState.error!,
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
```

## Example 4: Todo App with BLoC

### Events and States
```dart
abstract class TodoEvent {}

class LoadTodos extends TodoEvent {}

class AddTodo extends TodoEvent {
  final String title;
  AddTodo(this.title);
}

class ToggleTodo extends TodoEvent {
  final String id;
  ToggleTodo(this.id);
}

class DeleteTodo extends TodoEvent {
  final String id;
  DeleteTodo(this.id);
}

abstract class TodoState {}

class TodoInitial extends TodoState {}

class TodoLoading extends TodoState {}

class TodoLoaded extends TodoState {
  final List<Todo> todos;
  TodoLoaded(this.todos);
}

class TodoError extends TodoState {
  final String message;
  TodoError(this.message);
}

class Todo {
  final String id;
  final String title;
  final bool isCompleted;

  Todo({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  Todo copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
```

### BLoC Implementation
```dart
class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository repository;

  TodoBloc({required this.repository}) : super(TodoInitial()) {
    on<LoadTodos>(_onLoadTodos);
    on<AddTodo>(_onAddTodo);
    on<ToggleTodo>(_onToggleTodo);
    on<DeleteTodo>(_onDeleteTodo);
  }

  void _onLoadTodos(LoadTodos event, Emitter<TodoState> emit) async {
    emit(TodoLoading());
    try {
      final todos = await repository.getTodos();
      emit(TodoLoaded(todos));
    } catch (e) {
      emit(TodoError('Failed to load todos: \$e'));
    }
  }

  void _onAddTodo(AddTodo event, Emitter<TodoState> emit) async {
    if (state is TodoLoaded) {
      try {
        final newTodo = Todo(
          id: DateTime.now().toString(),
          title: event.title,
        );
        await repository.addTodo(newTodo);
        
        final currentTodos = (state as TodoLoaded).todos;
        emit(TodoLoaded([...currentTodos, newTodo]));
      } catch (e) {
        emit(TodoError('Failed to add todo: \$e'));
      }
    }
  }

  void _onToggleTodo(ToggleTodo event, Emitter<TodoState> emit) async {
    if (state is TodoLoaded) {
      try {
        final currentTodos = (state as TodoLoaded).todos;
        final updatedTodos = currentTodos.map((todo) {
          return todo.id == event.id
              ? todo.copyWith(isCompleted: !todo.isCompleted)
              : todo;
        }).toList();
        
        emit(TodoLoaded(updatedTodos));
        
        final updatedTodo = updatedTodos.firstWhere((todo) => todo.id == event.id);
        await repository.updateTodo(updatedTodo);
      } catch (e) {
        emit(TodoError('Failed to update todo: \$e'));
      }
    }
  }
}
```

### BLoC Consumer
```dart
class TodoListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TodoBloc(repository: TodoRepository())..add(LoadTodos()),
      child: Scaffold(
        appBar: AppBar(title: Text('Todo List')),
        body: BlocBuilder<TodoBloc, TodoState>(
          builder: (context, state) {
            if (state is TodoLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is TodoLoaded) {
              return ListView.builder(
                itemCount: state.todos.length,
                itemBuilder: (context, index) {
                  final todo = state.todos[index];
                  return ListTile(
                    title: Text(
                      todo.title,
                      style: TextStyle(
                        decoration: todo.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    leading: Checkbox(
                      value: todo.isCompleted,
                      onChanged: (_) => context.read<TodoBloc>().add(ToggleTodo(todo.id)),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => context.read<TodoBloc>().add(DeleteTodo(todo.id)),
                    ),
                  );
                },
              );
            } else if (state is TodoError) {
              return Center(
                child: Text(
                  'Error: \${state.message}',
                  style: TextStyle(color: Colors.red),
                ),
              );
            }
            return Center(child: Text('No todos yet'));
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddTodoDialog(context),
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
```''';

      case 'exercises':
        return '''# State Management Exercises

## Exercise 1: Counter App Evolution

### Part A: Basic Counter (setState)
Create a simple counter app using StatefulWidget and setState() with the following features:
- Display current count
- Increment button
- Decrement button
- Reset button
- Display count in different colors based on value (negative = red, zero = gray, positive = green)

### Part B: Enhanced Counter (Provider)
Refactor the counter app to use Provider:
- Create a CounterModel with ChangeNotifier
- Add increment, decrement, and reset methods
- Implement step size functionality (increment/decrement by custom amount)
- Add history tracking (last 10 operations)
- Create separate widgets for display and controls that share the same state

### Part C: Multi-Counter (Riverpod)
Extend the app to manage multiple counters:
- Create multiple named counters
- Each counter maintains its own state
- Display sum of all counters
- Add/remove counters dynamically
- Persist counter states using SharedPreferences

### Success Criteria
- Clean separation between UI and business logic
- Proper state management patterns implementation
- No unnecessary rebuilds
- Proper resource disposal

## Exercise 2: Shopping Cart Application

### Core Requirements
Build a complete shopping cart application with the following features:

#### Product Catalog
- Display list of products with images, names, and prices
- Search and filter functionality
- Category-based organization
- Product detail view with descriptions

#### Shopping Cart Management
- Add products to cart
- Update quantities
- Remove items from cart
- Calculate totals including tax and shipping
- Apply discount codes
- Save cart state between app sessions

#### User Experience Features
- Loading states during operations
- Error handling for network failures
- Optimistic updates for better UX
- Empty states with appropriate messaging
- Confirmation dialogs for destructive actions

### Technical Implementation
Choose one of the following state management approaches:

#### Option A: Provider Implementation
- Create ProductProvider for catalog management
- Implement CartProvider with ChangeNotifier
- Use Consumer widgets for reactive UI updates
- Handle async operations with FutureProvider

#### Option B: Riverpod Implementation
- Use StateNotifierProvider for complex state
- Implement FutureProvider for API calls
- Create family providers for parameterized data
- Add proper error handling and loading states

#### Option C: BLoC Implementation
- Design events for all user interactions
- Create comprehensive state classes
- Implement proper event-to-state mappings
- Add repository pattern for data access

### Advanced Features
- User authentication and personalized carts
- Product recommendations based on cart contents
- Social sharing of cart contents
- Integration with payment gateways
- Order history and tracking

## Exercise 3: Real-Time Chat Application

### Application Requirements
Develop a real-time messaging app that demonstrates advanced state management concepts:

#### Core Messaging Features
- Send and receive text messages
- Display message timestamps
- Show message delivery status
- Support for message editing and deletion
- Typing indicators
- Online/offline user status

#### Advanced Features
- Message threading and replies
- File and image sharing
- Push notifications
- Message search functionality
- Chat room creation and management
- User profiles and presence

### State Management Challenges

#### Real-Time Data Synchronization
- WebSocket connection management
- Optimistic UI updates
- Conflict resolution for simultaneous edits
- Message ordering and deduplication
- Connection retry logic

#### Complex State Coordination
- Multiple chat rooms with independent state
- User presence across different rooms
- Message caching and persistence
- Unread message counting
- Background sync when app is inactive

#### Performance Considerations
- Efficient list rendering for large message histories
- Memory management for media files
- Network optimization for poor connections
- Battery usage optimization
- Smooth scrolling with dynamic content

### Implementation Options

#### Stream-Based Approach (Riverpod)
- Use StreamProvider for real-time updates
- Implement proper stream subscription management
- Handle stream errors and reconnection
- Cache stream data for offline access

#### Event-Driven Architecture (BLoC)
- Design comprehensive event system
- Implement state machines for connection management
- Handle complex async workflows
- Add proper error recovery mechanisms

#### Hybrid Approach
- Combine multiple state management solutions
- Use appropriate tool for each use case
- Maintain clear boundaries between different state layers
- Ensure consistent data flow patterns

## Exercise 4: Task Management Dashboard

### Project Overview
Create a comprehensive task management application similar to Trello or Asana with advanced state management requirements.

#### Core Features
- Multiple project boards
- Task creation, editing, and deletion
- Task assignment to team members
- Due date management and reminders
- Priority levels and categorization
- Progress tracking and completion status

#### Advanced Functionality
- Drag-and-drop task reordering
- Real-time collaboration with multiple users
- Comment threads on tasks
- File attachments and media support
- Time tracking and reporting
- Offline capability with sync

### State Management Architecture

#### Multi-Layer State Design
1. **Local UI State**: Drag operations, form inputs, temporary selections
2. **Application State**: Current user, active project, navigation state
3. **Domain State**: Tasks, projects, users, comments
4. **Synchronization State**: Pending uploads, conflict resolution, offline queue

#### Complex State Relationships
- Tasks belong to projects and users
- Comments are associated with tasks and users
- Permissions vary by user role and project
- Changes need to propagate to all connected clients
- Offline changes must be queued and synchronized

### Technical Challenges

#### Performance Optimization
- Virtualized lists for large task collections
- Intelligent caching strategies
- Selective state updates to minimize rebuilds
- Background sync without blocking UI
- Memory management for large datasets

#### Data Consistency
- Optimistic updates with rollback capability
- Conflict resolution for simultaneous edits
- Proper error handling and user feedback
- Transaction-like operations for complex updates
- Audit trails for change tracking

#### User Experience
- Smooth animations during state transitions
- Progressive loading for large datasets
- Intuitive error messages and recovery options
- Offline indicators and sync status
- Responsive design for different screen sizes

### Assessment Criteria

#### Architecture Quality (30%)
- Clean separation of concerns
- Appropriate state management tool selection
- Scalable and maintainable code structure
- Proper error handling strategies
- Well-documented code and architecture decisions

#### Functionality Implementation (25%)
- Complete feature implementation
- Proper handling of edge cases
- Good user experience design
- Performance optimization
- Cross-platform compatibility

#### State Management Excellence (25%)
- Efficient state updates and minimal rebuilds
- Proper resource management and disposal
- Consistent state management patterns
- Good testing coverage for state logic
- Documentation of state flow and dependencies

#### Code Quality and Best Practices (20%)
- Clean, readable, and well-organized code
- Proper use of design patterns
- Comprehensive error handling
- Good documentation and comments
- Version control best practices

### Deliverables
1. Complete Flutter application with source code
2. Architecture documentation explaining state management decisions
3. Unit tests for state management logic
4. Integration tests for key user workflows
5. Performance analysis and optimization report
6. Deployment guide and configuration instructions
7. User manual and feature documentation

### Bonus Challenges
- Implement real-time collaborative features
- Add comprehensive analytics and reporting
- Create admin dashboard for user management
- Implement advanced search and filtering
- Add integration with external calendar systems
- Build API for third-party integrations''';

      case 'videos':
        return '''# State Management Video Learning Resources

## Comprehensive Learning Paths

### **Flutter Official Channel** - State Management Fundamentals
**Duration**: 3-5 hours across multiple videos
**Level**: Beginner to Intermediate
**Why Essential**: Official Flutter team explanations and best practices
**Key Videos**:
- "Flutter State Management: The Big Picture"
- "Provider Package Deep Dive"
- "When to Use setState vs Provider"
- "Flutter Architecture Patterns"

### **Reso Coder** - Complete State Management Series
**Duration**: 8-12 hours comprehensive coverage
**Level**: Beginner to Advanced
**Strength**: Detailed explanations with practical examples
**Coverage**: setState, Provider, BLoC, Riverpod, GetX
**Best For**: Systematic learning of all major approaches

### **Flutter Mapp** - Advanced State Management
**Duration**: 6-8 hours across multiple series  
**Level**: Intermediate to Advanced
**Focus**: Real-world implementation patterns
**Special Value**: Production-ready code examples

## Provider-Focused Content

### **The Net Ninja** - Flutter Provider Tutorial Series
**Duration**: 4-6 hours
**Level**: Beginner to Intermediate
**Format**: Step-by-step project-based learning
**Project**: Complete coffee shop app with Provider
**Strength**: Clear progression from simple to complex state

### **Santos Enoque** - Provider Best Practices
**Duration**: 2-3 hours
**Level**: Intermediate
**Focus**: Advanced Provider patterns and optimization
**Topics**: MultiProvider, ProxyProvider, Consumer optimization
**Value**: Production-level Provider usage

### **Code With Andrea** - Provider Architecture Patterns
**Duration**: 3-4 hours
**Level**: Intermediate to Advanced
**Focus**: Clean architecture with Provider
**Coverage**: Repository pattern, dependency injection, testing
**Authority**: Industry expert with extensive Flutter experience

## Riverpod Mastery

### **Riverpod Creator (Remi Rousselet)** - Official Tutorials
**Duration**: 5-7 hours across multiple presentations
**Level**: Intermediate to Advanced
**Authority**: Created by Riverpod's author
**Content**: Philosophy, migration from Provider, advanced patterns
**Must-Watch**: Conference talks and workshop recordings

### **Code With Andrea** - Riverpod Complete Course
**Duration**: 10-15 hours comprehensive course
**Level**: Beginner to Expert
**Format**: Complete e-commerce project implementation
**Coverage**: All Riverpod providers, testing, architecture
**Investment**: Premium course with exceptional depth

### **Fun With Flutter** - Riverpod Quick Start
**Duration**: 2-3 hours
**Level**: Beginner to Intermediate
**Focus**: Quick introduction and common patterns
**Best For**: Developers already familiar with Provider

## BLoC Pattern Expertise

### **Bloc Library Official** - Complete BLoC Course
**Duration**: 8-10 hours
**Level**: Intermediate to Advanced
**Authority**: Official BLoC library documentation team
**Coverage**: Counter app to complex enterprise applications
**Value**: Authoritative source for BLoC patterns

### **Flutter Bloc Tutorial** - ResoCoder BLoC Series
**Duration**: 6-8 hours
**Level**: Intermediate
**Project**: Weather app with clean architecture
**Focus**: Real-world BLoC implementation
**Strength**: Clean code and testing practices

### **Very Good Ventures** - Advanced BLoC Patterns
**Duration**: 4-5 hours across conference talks
**Level**: Advanced
**Content**: Enterprise-level BLoC architecture
**Authority**: Team behind many large Flutter applications

## Comparative Analysis

### **Fireship** - Flutter State Management in 100 Seconds
**Duration**: 2 minutes per concept
**Level**: All levels
**Format**: Quick overviews and comparisons
**Best For**: Getting started or quick refreshers
**Coverage**: setState, Provider, BLoC, GetX, MobX

### **Flutter Explained** - State Management Comparison
**Duration**: 45-60 minutes
**Level**: Intermediate
**Format**: Side-by-side implementation comparison
**Value**: Helps choose appropriate solution
**Projects**: Same app built with different state management approaches

### **Marcus Ng** - When to Use Which State Management
**Duration**: 30-40 minutes
**Level**: Intermediate to Advanced
**Focus**: Decision-making framework
**Content**: Project size, team size, complexity considerations

## Real-World Project Implementations

### **Flutter Developers** - E-commerce App Series
**Duration**: 12-15 hours complete project
**Level**: Intermediate to Advanced
**State Management**: Provider + Repository pattern
**Features**: Shopping cart, user authentication, payment integration
**Value**: Production-ready application development

### **Johannes Milke** - Social Media App
**Duration**: 8-10 hours
**Level**: Advanced
**Technologies**: BLoC + Firebase + Clean Architecture
**Features**: Real-time messaging, posts, user profiles
**Strength**: Complex state relationships and real-time updates

### **dbestech** - Food Delivery App
**Duration**: 20+ hours complete series
**Level**: Intermediate to Advanced
**Architecture**: GetX (with comparison to other solutions)
**Scale**: Large application with multiple features
**Coverage**: State management, navigation, dependency injection

## Architecture and Patterns

### **Robert C Martin (Uncle Bob)** - Clean Architecture Principles
**Duration**: 1-2 hours (Flutter-applicable principles)
**Level**: Advanced
**Focus**: Architectural principles applicable to Flutter
**Value**: Foundation for scalable state management
**Application**: How to apply SOLID principles in Flutter state management

### **Andrea Bizzotto** - Flutter Architecture Samples
**Duration**: 3-4 hours across multiple videos
**Level**: Advanced
**Content**: Multiple architecture approaches with state management
**Repository**: Companion GitHub repository with code samples
**Authority**: Recognized Flutter architecture expert

### **Google I/O Flutter Sessions** - State Management Evolution
**Duration**: 45-60 minutes per session
**Level**: Intermediate to Advanced
**Content**: Latest recommendations and future directions
**Value**: Official guidance from Google's Flutter team
**Updates**: Annual updates on best practices

## Testing and Quality Assurance

### **Flutter Test Driven Development** - State Testing
**Duration**: 4-5 hours
**Level**: Intermediate to Advanced
**Focus**: Testing state management logic
**Coverage**: Unit tests, widget tests, integration tests
**Tools**: mockito, bloc_test, provider testing

### **Code With Andrea** - Testing Flutter Apps
**Duration**: 6-8 hours comprehensive course
**Level**: Intermediate to Advanced
**State Focus**: Testing Provider and Riverpod applications
**Practices**: TDD, mocking, test organization
**Quality**: Professional testing practices

## Performance and Optimization

### **Flutter Performance** - State Management Impact
**Duration**: 2-3 hours across multiple videos
**Level**: Advanced
**Focus**: Performance implications of different state approaches
**Tools**: Flutter Inspector, performance profiling
**Optimization**: Reducing rebuilds, memory usage, battery impact

### **Very Good Ventures** - Flutter Performance Best Practices
**Duration**: 1-2 hours
**Level**: Advanced
**Content**: Enterprise-level performance considerations
**State Management**: Optimization techniques for large applications

## Community and Advanced Topics

### **Flutter Community** - State Management Debates
**Duration**: Various lengths (30-90 minutes)
**Level**: All levels
**Format**: Panel discussions, interviews, Q&A sessions
**Value**: Multiple perspectives on state management choices
**Platforms**: Flutter podcast episodes, conference panels

### **London Flutter Meetup** - Advanced State Management
**Duration**: 45-60 minutes per talk
**Level**: Intermediate to Advanced
**Content**: Community presentations on specialized topics
**Value**: Real-world case studies and lessons learned

## Recommended Learning Progression

### Week 1-2: Foundations (10-15 hours)
1. Flutter Official setState and Provider videos (4 hours)
2. The Net Ninja Provider series (6 hours)
3. Fireship quick comparisons (1 hour)
4. Simple project implementation (4 hours)

### Week 3-4: Intermediate Concepts (12-16 hours)
1. Reso Coder comprehensive series (8 hours)
2. Code With Andrea Provider architecture (4 hours)
3. Flutter Explained comparisons (2 hours)
4. Medium complexity project (6 hours)

### Week 5-6: Advanced Patterns (15-20 hours)
1. Riverpod official tutorials (6 hours)
2. BLoC library course (8 hours)
3. Architecture pattern videos (4 hours)
4. Complex project implementation (8 hours)

### Week 7-8: Specialization (10-15 hours)
1. Choose specialization (Provider/Riverpod/BLoC)
2. Advanced patterns and optimization (6 hours)
3. Testing and quality assurance (4 hours)
4. Production project refinement (8 hours)

### Tips for Effective Learning
- **Code Along**: Always implement examples while watching
- **Compare Approaches**: Try the same feature with different state management solutions  
- **Join Communities**: Engage with Flutter Discord, Reddit, and Stack Overflow
- **Read Documentation**: Supplement videos with official package documentation
- **Build Projects**: Apply concepts in increasingly complex personal projects
- **Stay Updated**: Follow Flutter team and package maintainer announcements''';

      default:
        return 'Content for State Management will be available soon!';
    }
  }

  String _getFallbackContent(String promptType) {
    // Special case for HTML and CSS Foundations
    if (widget.moduleTitle.toLowerCase().contains('html') ||
        widget.moduleTitle.toLowerCase().contains('css') ||
        widget.moduleTitle.toLowerCase().contains('web')) {
      return _getWebDevelopmentContent(promptType);
    }

    // Special case for Machine Learning topics
    if (widget.moduleTitle.toLowerCase().contains('machine learning') ||
        widget.moduleTitle.toLowerCase().contains('ml') ||
        widget.moduleTitle.toLowerCase().contains('artificial intelligence') ||
        widget.moduleTitle.toLowerCase().contains('data science')) {
      return _getMachineLearningContent(promptType);
    }

    // Special case for Data Preprocessing
    if (widget.moduleTitle.toLowerCase().contains('data preprocessing') ||
        widget.moduleTitle.toLowerCase().contains('data cleaning') ||
        widget.moduleTitle.toLowerCase().contains('data preparation')) {
      return _getDataPreprocessingContent(promptType);
    }

    // Special case for State Management
    if (widget.moduleTitle.toLowerCase().contains('state management') ||
        widget.moduleTitle.toLowerCase().contains('flutter state') ||
        widget.moduleTitle.toLowerCase().contains('provider') ||
        widget.moduleTitle.toLowerCase().contains('riverpod') ||
        widget.moduleTitle.toLowerCase().contains('bloc')) {
      return _getStateManagementContent(promptType);
    }

    switch (promptType) {
      case 'content':
        return '''## 1.1 Introduction to ${widget.moduleTitle}

${widget.moduleTitle} are fundamental components of computer science that allow us to organize and manipulate data efficiently. They provide systematic ways of organizing, processing, retrieving, and storing data. A good understanding of ${widget.moduleTitle.toLowerCase()} ensures that programs are efficient and scalable.

Understanding ${widget.moduleTitle.toLowerCase()} is essential for any programmer or computer scientist, as they form the backbone of many algorithms and systems. By learning about different types of ${widget.moduleTitle.toLowerCase()} and their applications, you will be better equipped to choose the right data structure for your specific needs and optimize the performance of your programs.

The importance of ${widget.moduleTitle.toLowerCase()} lies in their ability to optimize algorithms. For example, searching for an element in an unsorted list can take O(n) time, while searching in a balanced binary search tree can be reduced to O(log n). From operating systems to artificial intelligence, almost every domain in computing relies on the clever use of ${widget.moduleTitle.toLowerCase()}.

## 1.2 Classification of ${widget.moduleTitle}

There are two broad categories of ${widget.moduleTitle.toLowerCase()}: Primitive and Non-Primitive.

### Primitive Data Structures
These are the basic structures directly available in most programming languages:
- **Integers**: Whole numbers for counting and calculations
- **Floats**: Decimal numbers for precise calculations
- **Characters**: Individual letters, symbols, or digits
- **Booleans**: True/false values for logical operations

### Non-Primitive Data Structures
These are more advanced and can be classified as:

#### Linear Data Structures
- **Arrays**: Fixed-size sequential collections of elements stored in contiguous memory
- **Linked Lists**: Dynamic collections where elements are connected via pointers
- **Stacks**: Last-In-First-Out (LIFO) data structures used for function calls and undo operations
- **Queues**: First-In-First-Out (FIFO) data structures used for scheduling and buffering

#### Non-Linear Data Structures
- **Trees**: Hierarchical structures with parent-child relationships used for searching and sorting
- **Graphs**: Networks of interconnected nodes used for social networks and routing
- **Hash Tables**: Key-value pair storage with fast access for databases and caches

## 1.3 Core Concepts of ${widget.moduleTitle}

The fundamental concepts of ${widget.moduleTitle.toLowerCase()} define their behavior and characteristics without specifying implementation details. They provide a clear understanding of functionality and practical applications.

Key characteristics of ADTs:
- **Encapsulation**: Hide implementation details from users
- **Interface Definition**: Specify what operations are available
- **Implementation Independence**: Allow multiple ways to implement the same ADT
- **Modularity**: Enable code reuse and maintainability

Common ADTs include Lists, Sets, Maps, Stacks, and Queues. Each ADT defines a set of operations that can be performed, such as insert, delete, search, and traverse.

## 1.4 Operations on ${widget.moduleTitle}

Fundamental operations that can be performed on ${widget.moduleTitle.toLowerCase()}:

1. **Insertion Operations**: Adding new elements to the structure
   - Insert at beginning, middle, or end
   - Handling capacity constraints
   - Maintaining structure properties

2. **Deletion Operations**: Removing elements from the structure
   - Delete by value or position
   - Handling empty structure cases
   - Memory deallocation considerations

3. **Search and Retrieval**: Finding specific elements within the structure
   - Linear search for unsorted data
   - Binary search for sorted data
   - Hash-based lookup for key-value pairs

4. **Traversal Operations**: Visiting all elements systematically
   - Sequential traversal for linear structures
   - Depth-first and breadth-first for trees and graphs
   - Iterator patterns for safe traversal

5. **Update Operations**: Modifying existing elements
   - Direct access modification
   - Conditional updates
   - Batch update operations

## 1.5 Time and Space Complexity

Performance analysis is crucial when working with ${widget.moduleTitle.toLowerCase()}:

### Time Complexity
- **Big O Notation**: Mathematical representation of algorithm efficiency
- **Best Case**: Optimal scenario performance (Ω notation)
- **Average Case**: Expected performance under typical conditions (Θ notation)
- **Worst Case**: Maximum time required (O notation)

### Space Complexity
- **Auxiliary Space**: Extra memory used by algorithms
- **In-place Operations**: Algorithms that use constant extra space
- **Memory Trade-offs**: Balancing time efficiency with space usage

### Complexity Comparison
Different ${widget.moduleTitle.toLowerCase()} have varying complexity characteristics:
- Arrays: O(1) access, O(n) insertion/deletion
- Linked Lists: O(n) access, O(1) insertion/deletion at known position
- Hash Tables: O(1) average access, O(n) worst case
- Balanced Trees: O(log n) for most operations

## 1.6 Choosing the Right ${widget.moduleTitle}

Factors to consider when selecting appropriate ${widget.moduleTitle.toLowerCase()}:

### Performance Requirements
- **Access Patterns**: Random vs sequential access needs
- **Operation Frequency**: Which operations are performed most often
- **Data Size**: Small datasets vs large-scale applications
- **Real-time Constraints**: Response time requirements

### Memory Constraints
- **Available Memory**: Total memory budget
- **Memory Locality**: Cache-friendly access patterns
- **Dynamic vs Static**: Fixed size vs growing datasets

### Use Case Analysis
- **Read-Heavy**: Optimize for fast retrieval
- **Write-Heavy**: Optimize for fast insertion/deletion
- **Mixed Workloads**: Balance between different operations

## 1.7 Memory Management for ${widget.moduleTitle}

Understanding how ${widget.moduleTitle.toLowerCase()} are stored and managed in memory:

### Memory Layout
- **Contiguous Storage**: Arrays store elements in adjacent memory locations
- **Linked Storage**: Linked structures use pointers to connect elements
- **Hybrid Approaches**: Combining contiguous and linked storage

### Allocation Strategies
- **Static Allocation**: Fixed size determined at compile time
- **Dynamic Allocation**: Size determined at runtime
- **Memory Pools**: Pre-allocated memory blocks for efficiency

### Garbage Collection
- **Automatic Management**: Language-managed memory cleanup
- **Manual Management**: Programmer-controlled allocation/deallocation
- **Reference Counting**: Tracking object usage for cleanup

## 1.8 Practical Examples and Applications

Real-world implementations of ${widget.moduleTitle}:

### Database Systems
- **B-trees**: For efficient disk-based storage and retrieval
- **Hash Indexes**: For fast key-based lookups
- **Bloom Filters**: For probabilistic membership testing

### Operating Systems
- **Process Queues**: For CPU scheduling
- **Memory Management**: Using trees and lists for allocation
- **File Systems**: Directory structures using trees

### Web Development
- **Session Storage**: Hash tables for user session data
- **Caching**: LRU caches using linked lists and hash maps
- **URL Routing**: Trie structures for efficient path matching

### Mobile Applications
- **Contact Lists**: Sorted arrays or trees for quick lookup
- **Message Queues**: For handling asynchronous operations
- **Image Processing**: Arrays for pixel manipulation

### Game Development
- **Spatial Partitioning**: Quadtrees and octrees for collision detection
- **Pathfinding**: Graphs for navigation algorithms
- **Inventory Systems**: Hash tables for item management

## 1.9 Review and Best Practices

### Key Concepts Summary
- ${widget.moduleTitle} provide efficient ways to organize and manipulate data
- Choice of data structure significantly impacts program performance
- Understanding complexity analysis helps in making informed decisions
- Abstract Data Types provide clean interfaces for data manipulation

### Common Mistakes to Avoid
- **Premature Optimization**: Choose simple structures first, optimize when needed
- **Ignoring Memory Usage**: Consider space complexity alongside time complexity
- **Not Considering Access Patterns**: Match data structure to usage patterns
- **Over-engineering**: Use the simplest structure that meets requirements

### Best Practices
- **Profile Before Optimizing**: Measure actual performance bottlenecks
- **Consider Maintenance**: Choose structures that are easy to understand and modify
- **Document Assumptions**: Clearly state expected usage patterns and constraints
- **Test Edge Cases**: Verify behavior with empty, single-element, and large datasets

### Performance Optimization Tips
- **Cache-Friendly Access**: Prefer contiguous memory layouts when possible
- **Minimize Allocations**: Reuse objects and use object pools
- **Batch Operations**: Group related operations to reduce overhead
- **Monitor Memory Usage**: Track allocation patterns and optimize accordingly''';

      case 'simplified':
        return '''## ${widget.moduleTitle} - Key Points

• **What it is**: ${widget.moduleTitle} help organize and store data efficiently
• **Why important**: Makes programs faster and more organized
• **Main types**: Arrays, Lists, Trees, Graphs, Hash Tables
• **Common uses**: Databases, websites, mobile apps, games

## Quick Summary
- Start with basic concepts
- Practice with examples
- Understand when to use each type
- Focus on real-world applications

## Remember
${widget.moduleTitle} are the building blocks of efficient programming!''';

      case 'quiz':
        return '''## Quiz: ${widget.moduleTitle}

### Question 1
What is the main purpose of ${widget.moduleTitle}?
A) To make programming harder
B) To organize and store data efficiently
C) To slow down programs
D) To confuse developers

**Answer: B) To organize and store data efficiently**

### Question 2
Which is an example of a linear data structure?
A) Tree
B) Graph
C) Array
D) Hash Table

**Answer: C) Array**

### Question 3
What does LIFO stand for?
A) Last In, First Out
B) Last In, Final Out
C) Linear In, First Out
D) List In, First Out

**Answer: A) Last In, First Out**

### Question 4
Which operation adds elements to a data structure?
A) Deletion
B) Search
C) Insertion
D) Traversal

**Answer: C) Insertion**

### Question 5
What is Big O notation used for?
A) Naming variables
B) Measuring algorithm complexity
C) Creating loops
D) Defining functions

**Answer: B) Measuring algorithm complexity**''';

      case 'examples':
        return '''## Examples: ${widget.moduleTitle}

### Example 1: Array Implementation
```java
// Creating and using an array
int[] numbers = {1, 2, 3, 4, 5};
System.out.println("First element: " + numbers[0]);
System.out.println("Array length: " + numbers.length);
```

**Explanation**: Arrays store elements in contiguous memory locations, allowing fast access by index.

### Example 2: Stack Operations
```java
Stack<Integer> stack = new Stack<>();
stack.push(10);  // Add element
stack.push(20);
int top = stack.pop();  // Remove and return top element
System.out.println("Popped: " + top);  // Output: 20
```

**Explanation**: Stacks follow LIFO principle - last element added is first to be removed.

### Example 3: Queue Operations
```java
Queue<String> queue = new LinkedList<>();
queue.offer("First");   // Add to rear
queue.offer("Second");
String front = queue.poll();  // Remove from front
System.out.println("Removed: " + front);  // Output: First
```

**Explanation**: Queues follow FIFO principle - first element added is first to be removed.''';

      case 'videos':
        return '''## Video Recommendations: ${widget.moduleTitle}

### Recommended YouTube Searches:
1. "${widget.moduleTitle} tutorial for beginners"
2. "${widget.moduleTitle} explained with examples"
3. "${widget.moduleTitle} implementation in Java"
4. "${widget.moduleTitle} vs other data structures"
5. "${widget.moduleTitle} interview questions"

### Popular Channels to Check:
• **CS Dojo** - Clear explanations with animations
• **mycodeschool** - Detailed data structure tutorials
• **Abdul Bari** - Comprehensive algorithm explanations
• **GeeksforGeeks** - Quick concept reviews
• **Coding Interview University** - Interview preparation

### What to Look For:
- Visual animations showing how operations work
- Step-by-step implementation guides
- Comparison with other data structures
- Real-world application examples
- Practice problems and solutions''';

      default:
        return 'Content for ${widget.moduleTitle} will be available soon!';
    }
  }

  String _getLearningStyleTips(String style) {
    switch (style) {
      case 'Visual':
        return 'Focus on diagrams, charts, and visual representations. Look for patterns and use colors to organize information.';
      case 'Auditory':
        return 'Read content aloud, discuss concepts, and listen to explanations. Use verbal repetition to reinforce learning.';
      case 'Reading/Writing':
        return 'Take detailed notes, create summaries, and rewrite key concepts. Use lists and written exercises.';
      case 'Kinesthetic':
        return 'Apply concepts practically, use hands-on examples, and take breaks to move around while studying.';
      default:
        return 'Use a combination of different learning approaches to maximize understanding.';
    }
  }

  Future<bool> _hasCompletedVARK() async {
    final learningStyle = await ActivityService.getLearningStyle();
    return learningStyle != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasCompletedVARK(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return _buildModuleContent();
      },
    );
  }

  Widget _buildModuleContent() {
    return Scaffold(
      backgroundColor: const Color(0xFF10141A),
      appBar: AppBar(
        title: Text(
          widget.moduleTitle,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF10141A),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (widget.learningStyle != null)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.learningStyle!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "Content"),
            Tab(text: "Simplified"),
            Tab(text: "Quiz"),
            Tab(text: "Examples"),
            Tab(text: "Videos"),
          ],
        ),
      ),
      body: Column(
        children: [
          // Learning style header if available
          if (widget.learningStyle != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade900,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade700),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology,
                          color: Colors.blue.shade300, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.learningStyle} Learning Style',
                        style: TextStyle(
                          color: Colors.blue.shade300,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getLearningStyleTips(widget.learningStyle!),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildContentTab('content'),
                _buildContentTab('simplified'),
                _buildContentTab('quiz'),
                _buildContentTab('examples'),
                _buildVideosTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final skillLevel =
              await ActivityService.getSkillLevel() ?? 'Beginner';
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseCompletionQuizScreen(
                courseTitle: widget.courseTitle ?? 'Course',
                moduleTitle: widget.moduleTitle,
                learningStyle: widget.learningStyle ?? 'Visual',
                skillLevel: skillLevel,
              ),
            ),
          );
        },
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.quiz),
        label: const Text(
          'Take Final Quiz',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildContentTab(String contentType) {
    final future = _contentCache.putIfAbsent(
      contentType,
      () => _generateContent(contentType),
    );

    return FutureBuilder<String>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.blue),
                SizedBox(height: 16),
                Text(
                  'Generating content...',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      color: Colors.red.shade400, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    "Error: ${snapshot.error}",
                    style: const TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _contentCache.remove(contentType);
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return _buildStructuredContent(
            snapshot.data ?? "No content generated.");
      },
    );
  }

  Widget _buildStructuredContent(String content) {
    // Split content into sections based on ## headers
    final sections = <Map<String, String>>[];
    final lines = content.split('\n');
    String currentSection = '';
    String currentContent = '';

    for (String line in lines) {
      if (line.startsWith('## ')) {
        // Save previous section if exists
        if (currentSection.isNotEmpty) {
          sections.add({
            'title': currentSection,
            'content': currentContent.trim(),
          });
        }
        // Start new section
        currentSection = line.substring(3).trim();
        currentContent = '';
      } else {
        currentContent += line + '\n';
      }
    }

    // Add the last section
    if (currentSection.isNotEmpty) {
      sections.add({
        'title': currentSection,
        'content': currentContent.trim(),
      });
    }

    // If no sections found, show content as single block
    if (sections.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2328),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade700),
          ),
          child: SelectableText(
            content,
            style: const TextStyle(
              color: Colors.white70,
              height: 1.6,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final section = sections[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2328),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade700, width: 0.5),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              title: Text(
                section['title']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              iconColor: Colors.blue.shade400,
              collapsedIconColor: Colors.grey.shade500,
              backgroundColor: const Color(0xFF1E2328),
              collapsedBackgroundColor: const Color(0xFF1E2328),
              initiallyExpanded:
                  index == 0, // First section expanded by default
              tilePadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              childrenPadding: EdgeInsets.zero,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SelectableText(
                    _formatContent(section['content']!),
                    style: const TextStyle(
                      color: Colors.white70,
                      height: 1.5,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatContent(String content) {
    // Format the content to handle markdown-like formatting without visual emoji indicators
    String formatted = content;

    // Handle code blocks (preserve them)
    final codeBlockRegex = RegExp(r'```[\s\S]*?```');
    final codeBlocks = <String>[];
    var codeBlockCounter = 0;

    formatted = formatted.replaceAllMapped(codeBlockRegex, (match) {
      final placeholder = '___CODEBLOCK_${codeBlockCounter}___';
      codeBlocks.add(match.group(0)!);
      codeBlockCounter++;
      return placeholder;
    });

    // Format markdown elements - Clean formatting without emojis
    formatted = formatted
        // Headers - Clean subsection headers
        .replaceAllMapped(
            RegExp(r'^### (.+)$', multiLine: true),
            (match) =>
                '\n\n${match.group(1)!}\n${'=' * match.group(1)!.length}\n')
        .replaceAllMapped(
            RegExp(r'^#### (.+)$', multiLine: true),
            (match) =>
                '\n\n${match.group(1)!}\n${'-' * match.group(1)!.length}\n')
        // Bold text - Clean emphasis without emojis
        .replaceAllMapped(
            RegExp(r'\*\*(.+?)\*\*'), (match) => match.group(1)!.toUpperCase())
        // Italic text - Simple emphasis
        .replaceAllMapped(RegExp(r'\*(.+?)\*'), (match) => match.group(1)!)
        // Inline code - Clean code formatting
        .replaceAllMapped(RegExp(r'`(.+?)`'), (match) => '[${match.group(1)!}]')
        // Bullet points - Clean bullets
        .replaceAllMapped(RegExp(r'^- (.+)$', multiLine: true),
            (match) => '• ${match.group(1)!}')
        // Numbered lists - Keep as is
        .replaceAllMapped(RegExp(r'^\d+\. (.+)$', multiLine: true),
            (match) => '${match.group(0)!}');

    // Restore code blocks
    for (int i = 0; i < codeBlocks.length; i++) {
      formatted = formatted.replaceAll('___CODEBLOCK_${i}___', codeBlocks[i]);
    }

    return formatted.trim();
  }

  Widget _buildVideosTab() {
    return _YouTubeVideosWidget(
      moduleTitle: widget.moduleTitle,
      searchQuery: widget.moduleTitle,
    );
  }
}

class _YouTubeVideosWidget extends StatefulWidget {
  final String moduleTitle;
  final String searchQuery;

  const _YouTubeVideosWidget({
    required this.moduleTitle,
    required this.searchQuery,
  });

  @override
  State<_YouTubeVideosWidget> createState() => _YouTubeVideosWidgetState();
}

class _YouTubeVideosWidgetState extends State<_YouTubeVideosWidget> {
  List<YouTubeVideo> _videos = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final videos = await YouTubeService.searchVideos(
        query: widget.searchQuery,
        maxResults: 6,
      );
      if (mounted) {
        setState(() {
          _videos = videos;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade900, Colors.red.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.play_circle_fill, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Video Learning: ${widget.moduleTitle}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Watch curated YouTube videos to enhance your understanding of ${widget.moduleTitle}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => YouTubeSearchScreen(
                          initialQuery: widget.searchQuery,
                          moduleTitle: widget.moduleTitle,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.search),
                  label: const Text('Search More Videos'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _loadVideos,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Content section
          if (_isLoading)
            _buildLoadingWidget()
          else if (_error != null)
            _buildErrorWidget()
          else if (_videos.isEmpty)
            _buildEmptyWidget()
          else
            _buildVideosGrid(),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        child: const Column(
          children: [
            CircularProgressIndicator(color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Loading YouTube videos...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade300),
        ),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[700]),
            const SizedBox(height: 12),
            Text(
              'Failed to load YouTube videos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!.contains('API key')
                  ? 'YouTube API key not configured. Please check your .env file.'
                  : _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[600]),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: _loadVideos,
                  child: const Text('Retry'),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => YouTubeSearchScreen(
                          initialQuery: widget.searchQuery,
                          moduleTitle: widget.moduleTitle,
                        ),
                      ),
                    );
                  },
                  child: const Text('Search Manually'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.video_library_outlined,
                size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No videos found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => YouTubeSearchScreen(
                      initialQuery: widget.searchQuery,
                      moduleTitle: widget.moduleTitle,
                    ),
                  ),
                );
              },
              child: const Text('Search Videos'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideosGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommended Videos (${_videos.length})',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _videos.length,
          itemBuilder: (context, index) {
            final video = _videos[index];
            return YouTubeVideoWidget(
              video: video,
              showDescription: false,
              onTap: () => _showVideoDetails(video),
            );
          },
        ),
        const SizedBox(height: 20),
        Center(
          child: TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => YouTubeSearchScreen(
                    initialQuery: widget.searchQuery,
                    moduleTitle: widget.moduleTitle,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.video_library),
            label: const Text('View All Videos'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue[400],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  void _showVideoDetails(YouTubeVideo video) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(video.title),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height * 0.5,
          child: YouTubeVideoWidget(
            video: video,
            showEmbed: true,
            showDescription: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
