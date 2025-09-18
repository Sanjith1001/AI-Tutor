import 'package:flutter/material.dart';
import '../services/groq_service.dart';
import '../services/activity_service.dart';
import 'course_completion_quiz_screen.dart';

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
        prompt = '''Create comprehensive educational content for "${widget.moduleTitle}" in the following structured format. Make it detailed like a professional textbook chapter:

## 1.1 Introduction to ${widget.moduleTitle}
Write 3-4 detailed paragraphs explaining:
- What ${widget.moduleTitle} are and their fundamental purpose
- Why they are crucial in computer science and programming
- Their role in algorithm efficiency and software development
- How they impact real-world applications

## 1.2 Classification of ${widget.moduleTitle}
Provide detailed categorization with explanations:
- Primary categories and their characteristics
- Subcategories with specific examples
- When to use each type
- Advantages and disadvantages of each category

## 1.3 Abstract Data Types (ADTs)
Explain the concept of abstract data types related to ${widget.moduleTitle}:
- Definition and importance of ADTs
- Common ADT operations
- Interface vs implementation
- Examples of ADTs in ${widget.moduleTitle}

## 1.4 Operations on ${widget.moduleTitle}
Detail the fundamental operations:
1. Insertion operations and their variations
2. Deletion operations and edge cases
3. Search and retrieval methods
4. Traversal techniques
5. Update and modification operations

## 1.5 Time and Space Complexity
Comprehensive analysis of performance:
- Big O notation explanation
- Time complexity for different operations
- Space complexity considerations
- Best, average, and worst-case scenarios
- Comparison between different implementations

## 1.6 Choosing the Right ${widget.moduleTitle}
Guidelines for selection:
- Factors to consider when choosing
- Performance requirements analysis
- Memory constraints
- Use case scenarios

## 1.7 Memory Management for ${widget.moduleTitle}
Explain memory considerations:
- How ${widget.moduleTitle} are stored in memory
- Memory allocation strategies
- Garbage collection implications
- Memory optimization techniques

## 1.8 Practical Examples and Applications
Real-world implementations:
- Database systems usage
- Operating system applications
- Web development scenarios
- Mobile app implementations
- Game development uses

## 1.9 Review and Best Practices
Summary and guidelines:
- Key concepts recap
- Common mistakes to avoid
- Best practices for implementation
- Performance optimization tips

Make each section comprehensive with detailed explanations, examples, and practical insights.''';
        break;
      case 'simplified':
        prompt = 'Simplify "${widget.moduleTitle}" into key bullet points and easy-to-understand concepts for beginners.';
        break;
      case 'quiz':
        prompt = 'Generate 5 multiple-choice questions with answers for "${widget.moduleTitle}". Format as Q1: question, A) option B) option C) option D) option, Answer: correct option.';
        break;
      case 'examples':
        prompt = 'Provide 3 practical examples and code snippets (if applicable) for "${widget.moduleTitle}" with detailed explanations.';
        break;
      case 'videos':
        prompt = 'Suggest 5 YouTube search terms and video topics that would help someone learn "${widget.moduleTitle}".';
        break;
    }

    // Add learning style specific instructions
    if (widget.learningStyle != null) {
      switch (widget.learningStyle) {
        case 'Visual':
          prompt += ' Focus on visual descriptions, suggest diagrams, and use formatting that helps visual learners.';
          break;
        case 'Auditory':
          prompt += ' Structure the explanation for reading aloud and include discussion points.';
          break;
        case 'Reading/Writing':
          prompt += ' Provide detailed written explanations with clear structure and key points.';
          break;
        case 'Kinesthetic':
          prompt += ' Include practical examples and hands-on activities where possible.';
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
      return _getFallbackContent(promptType);
    }
  }

  String _getFallbackContent(String promptType) {
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

## 1.3 Abstract Data Types (ADTs)

Abstract Data Types define the behavior of ${widget.moduleTitle.toLowerCase()} without specifying implementation details. They provide a clear interface between the data structure's functionality and its internal workings.

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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                      Icon(Icons.psychology, color: Colors.blue.shade300, size: 20),
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
          final skillLevel = await ActivityService.getSkillLevel() ?? 'Beginner';
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
                  Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
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

        return _buildStructuredContent(snapshot.data ?? "No content generated.");
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
              initiallyExpanded: index == 0, // First section expanded by default
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    // Format the content to handle markdown-like formatting
    return content
        .replaceAll('**', '') // Remove bold markers for now
        .replaceAll('### ', '\n• ') // Convert h3 to bullet points
        .replaceAll('#### ', '\n  ◦ ') // Convert h4 to sub-bullets
        .replaceAll('- **', '\n• ') // Convert list items
        .replaceAll('- ', '\n• ') // Convert simple list items
        .trim();
  }

  Widget _buildVideosTab() {
    return FutureBuilder<String>(
      future: _contentCache.putIfAbsent('videos', () => _generateContent('videos')),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.blue),
                SizedBox(height: 16),
                Text(
                  'Finding video recommendations...',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.shade900,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.play_circle_fill, color: Colors.red.shade300, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Video Recommendations',
                          style: TextStyle(
                            color: Colors.red.shade300,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Search YouTube for: "${widget.moduleTitle}"',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (snapshot.hasData)
                      SelectableText(
                        snapshot.data!,
                        style: const TextStyle(
                          color: Colors.white70,
                          height: 1.6,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: Colors.grey.shade800,
                child: ListTile(
                  leading: Icon(Icons.video_library, color: Colors.red.shade400),
                  title: const Text(
                    'Open YouTube Search',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Search for "${widget.moduleTitle}" videos',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: const Icon(Icons.open_in_new, color: Colors.white70),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('YouTube integration coming soon!'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}