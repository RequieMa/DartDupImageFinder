## 0.1.0

* Initial implementation of `DupImageFinder` API for image duplicate detection:
  - Configurable hashing algorithms via `Hashing` interface
  - Dual search methods support (`BK-Tree` & brute-force [TODO])
  - Threshold-controlled hamming distance evaluation
  - Parallelizable hash encoding architecture [TODO]
  - Verbose logging for pipeline monitoring
  
* Implemented `HashEval` search subsystem:
  - BK-Tree based nearest neighbor search
  - Brute-force fallback implementation
  - Score-based result sorting capabilities
  - Query-result deduplication filters
  - Thread-safe query argument packaging

* Core enhancements:
  - Flexible result presentation (scores/keys only)
  - File existence validation checks
  - Recursive directory traversal support
  - Hamming distance wrapper abstraction
  - Hash value null-safety handling