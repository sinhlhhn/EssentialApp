# EssentialFeed

[![CI](https://github.com/sinhlhhn/EssentialFeed/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/sinhlhhn/EssentialFeed/actions/workflows/CI.yml)

Dive deep into practicing modular design and testing strategies.

- Flow TTD approach.
  - Always write tests before writing the production code.
  - Repeat 3 steps: see the failure -> make the test passed -> refactor code
 
- Use different testing strategies.
  - Unit test: It tests only one component at a time. It usually needs a test double like `stub` and `spy`. It is the primary testing strategy because it is fast, reliable, and cheap to write tests.
  - Integration test: It tests two or more components collaborating without `stub` and `spy`. It is the secondary testing strategy because it requires interaction directly with the infrastructure components like network, local storage, and file system. So it is slower and more fragile than unit tests.
  - Snapshot test: It is used to validate the UI of the app. It is the tertiary testing strategy because it relies on specific device details. So it is very fragile because a new iOS version or other system out of your control can break the test.
    
- Separate modules to achieve modular design
  ![image](https://github.com/sinhlhhn/EssentialFeed/assets/66399719/f45e9526-1b1b-4bdb-8fde-c5a836babf1f)

  - The main point is that the domain layer is at the center of the design and it does not depend on any other layer.
  - On the red layer, I have independent service implementations that depend on the domain layer.
  - On the blue layer, I have the infrastructure implementations and adapters to protect the inner layer from external frameworks such as URLSession, Firebase, UIKit, SwiftUI, CoreData, Realm, etc...
  - Moreover, the module in the same layer can also be decoupled. For example, `FeedAPI` and `FeedCache` modules are in the same red layer, but they don't know about each other.

- Apply Design pattern into practice
  - Decorator pattern: Add behavior to an individual object and extend its functionality without subclassing or changing the object's class. In the project, I only want the instance of `<FeedLoader>` that will be used in the UI to complete in the `Main queue`, instead of all the `<FeedLoader>` instances.
  - Strategy pattern: Define a family of algorithms, encapsulate each one, and make them interchangeable. In the project, I use different strategies for the `<FeedLoader>`. `LocalFeedLoader` to load feed from the cache and `RemoteFeedLoader` to load feed from the internet.
  - Adapter pattern: Convert the interface of a component into another interface a client expects. It enables you to decouple components from complex dependencies. In the project, `<FeedRefreshViewControllerDelegate>` lives in `Feed UI module` and `<FeedLoader>` lives in `Feed Feature module`. So I don't want `Feed Feedture module` to depend on `Feed UI module` so I created `FeedLoaderPresentationAdapter` to remove this dependency.
  - Composite pattern: Compose objects into a tree structure to represent part of whole hierarchies. It enables its client to treat individual objects and compositions of objects uniformly, through a single interface. In the project, I want the app to load from the internet first if it fails, I want it to load from the cache. So I created `FeedLoaderWithFallbackComposite` to implement the `<FeedLoader>` and has 2 properties that also conform to `<FeedLoader>` to perform the fallback logic.
