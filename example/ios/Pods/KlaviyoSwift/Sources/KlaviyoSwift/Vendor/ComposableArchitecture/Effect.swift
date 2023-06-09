/**
 MIT License

 Copyright (c) 2020 Point-Free, Inc.

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */
//
//  Effect.swift
//
//  Misc items pulled from https://github.com/pointfreeco/swift-composable-architecture related to the store.
//  Created by Noah Durell on 12/6/22.
//

import Combine
import Foundation

/// A type that encapsulates a unit of work that can be run in the outside world, and can feed
/// actions back to the ``Store``.
///
/// Effects are the perfect place to do side effects, such as network requests, saving/loading
/// from disk, creating timers, interacting with dependencies, and more. They are returned from
/// reducers so that the ``Store`` can perform the effects after the reducer is done running.
///
/// There are 2 distinct ways to create an `Effect`: one using Swift's native concurrency tools, and
/// the other using Apple's Combine framework:
///
/// * If using Swift's native structured concurrency tools then there are 3 main ways to create an
/// effect, depending on if you want to emit one single action back into the system, or any number
/// of actions, or just execute some work without emitting any actions:
///   * ``EffectPublisher/task(priority:operation:catch:file:fileID:line:)``
///   * ``EffectPublisher/run(priority:operation:catch:file:fileID:line:)``
///   * ``EffectPublisher/fireAndForget(priority:_:)``
/// * If using Combine in your application, in particular for the dependencies of your feature
/// then you can create effects by making use of any of Combine's operators, and then erasing the
/// publisher type to ``EffectPublisher`` with either `eraseToEffect` or `catchToEffect`. Note that
/// the Combine interface to ``EffectPublisher`` is considered soft deprecated, and you should
/// eventually port to Swift's native concurrency tools.
///
/// > Important: ``Store`` is not thread safe, and so all effects must receive values on the same
/// thread. This is typically the main thread,  **and** if the store is being used to drive UI then
/// it must receive values on the main thread.
/// >
/// > This is only an issue if using the Combine interface of ``EffectPublisher`` as mentioned
/// above. If  you are using Swift's concurrency tools and the `.task`, `.run` and `.fireAndForget`
/// functions on ``EffectTask``, then threading is automatically handled for you.
struct EffectPublisher<Action, Failure: Error> {
  @usableFromInline
  enum Operation {
    case none
    case publisher(AnyPublisher<Action, Failure>)
    case run(TaskPriority? = nil, @Sendable (Send<Action>) async -> Void)
  }

  @usableFromInline
  let operation: Operation

  @usableFromInline
  init(operation: Operation) {
    self.operation = operation
  }
}

// MARK: - Creating Effects

extension EffectPublisher {
  /// An effect that does nothing and completes immediately. Useful for situations where you must
  /// return an effect, but you don't need to do anything.
  @inlinable
  static var none: Self {
    Self(operation: .none)
  }
}

/// A convenience type alias for referring to an effect that can never fail, like the kind of
/// ``EffectPublisher`` returned by a reducer after processing an action.
///
/// Instead of specifying `Never` as `Failure`:
///
/// ```swift
/// func reduce(into state: inout State, action: Action) -> EffectPublisher<Action, Never> { … }
/// ```
///
/// You can specify a single generic:
///
/// ```swift
/// func reduce(into state: inout State, action: Action) -> EffectTask<Action>  { … }
/// ```
typealias EffectTask<Action> = EffectPublisher<Action, Never>

extension EffectPublisher where Failure == Never {
  /// Wraps an asynchronous unit of work in an effect.
  ///
  /// This function is useful for executing work in an asynchronous context and capturing the result
  /// in an ``EffectTask`` so that the reducer, a non-asynchronous context, can process it.
  ///
  /// For example, if your dependency exposes an `async` function, you can use
  /// ``task(priority:operation:catch:file:fileID:line:)`` to provide an asynchronous context for
  /// invoking that endpoint:
  ///
  /// ```swift
  /// struct Feature: ReducerProtocol {
  ///   struct State { … }
  ///   enum FeatureAction {
  ///     case factButtonTapped
  ///     case faceResponse(TaskResult<String>)
  ///   }
  ///   @Dependency(\.numberFact) var numberFact
  ///
  ///   func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
  ///     switch action {
  ///       case .factButtonTapped:
  ///         return .task { [number = state.number] in
  ///           await .factResponse(TaskResult { try await self.numberFact.fetch(number) })
  ///         }
  ///
  ///       case .factResponse(.success(fact)):
  ///         // do something with fact
  ///
  ///       case .factResponse(.failure):
  ///         // handle error
  ///
  ///       ...
  ///     }
  ///   }
  /// }
  /// ```
  ///
  /// The above code sample makes use of ``TaskResult`` in order to automatically bundle the success
  /// or failure of the `numberFact` endpoint into a single type that can be sent in an action.
  ///
  /// The closure provided to ``task(priority:operation:catch:file:fileID:line:)`` is allowed to
  /// throw, but any non-cancellation errors thrown will cause a runtime warning when run in the
  /// simulator or on a device, and will cause a test failure in tests. To catch non-cancellation
  /// errors use the `catch` trailing closure.
  ///
  /// - Parameters:
  ///   - priority: Priority of the underlying task. If `nil`, the priority will come from
  ///     `Task.currentPriority`.
  ///   - operation: The operation to execute.
  ///   - catch: An error handler, invoked if the operation throws an error other than
  ///     `CancellationError`.
  /// - Returns: An effect wrapping the given asynchronous work.
  static func task(
    priority: TaskPriority? = nil,
    operation: @escaping @Sendable () async throws -> Action,
    catch handler: (@Sendable (Error) async -> Action)? = nil,
    file: StaticString = #file,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self {
    return Self(
      operation: .run(priority) { send in
          do {
            try await send(operation())
          } catch is CancellationError {
            return
          } catch {
            guard let handler = handler else {
              #if DEBUG
//                var errorDump = ""
//                customDump(error, to: &errorDump, indent: 4)
                runtimeWarn(
                  """
                  An "EffectTask.task" returned from "\(fileID):\(line)" threw an unhandled error. …

                  \(error)

                  All non-cancellation errors must be explicitly handled via the "catch" parameter \
                  on "EffectTask.task", or via a "do" block.
                  """,
                  file: file,
                  line: line
                )
              #endif
              return
            }
            await send(handler(error))
          }
        }
    )
  }

  /// Wraps an asynchronous unit of work that can emit any number of times in an effect.
  ///
  /// This effect is similar to ``task(priority:operation:catch:file:fileID:line:)`` except it is
  /// capable of emitting 0 or more times, not just once.
  ///
  /// For example, if you had an async stream in a dependency client:
  ///
  /// ```swift
  /// struct EventsClient {
  ///   var events: () -> AsyncStream<Event>
  /// }
  /// ```
  ///
  /// Then you could attach to it in a `run` effect by using `for await` and sending each action of
  /// the stream back into the system:
  ///
  /// ```swift
  /// case .startButtonTapped:
  ///   return .run { send in
  ///     for await event in self.events() {
  ///       send(.event(event))
  ///     }
  ///   }
  /// ```
  ///
  /// See ``Send`` for more information on how to use the `send` argument passed to `run`'s closure.
  ///
  /// The closure provided to ``run(priority:operation:catch:file:fileID:line:)`` is allowed to
  /// throw, but any non-cancellation errors thrown will cause a runtime warning when run in the
  /// simulator or on a device, and will cause a test failure in tests. To catch non-cancellation
  /// errors use the `catch` trailing closure.
  ///
  /// - Parameters:
  ///   - priority: Priority of the underlying task. If `nil`, the priority will come from
  ///     `Task.currentPriority`.
  ///   - operation: The operation to execute.
  ///   - catch: An error handler, invoked if the operation throws an error other than
  ///     `CancellationError`.
  /// - Returns: An effect wrapping the given asynchronous work.
  static func run(
    priority: TaskPriority? = nil,
    operation: @escaping @Sendable (Send<Action>) async throws -> Void,
    catch handler: (@Sendable (Error, Send<Action>) async -> Void)? = nil,
    file: StaticString = #file,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self {
    return Self(
      operation: .run(priority) { send in
          do {
            try await operation(send)
          } catch is CancellationError {
            return
          } catch {
            guard let handler = handler else {
              #if DEBUG
//                var errorDump = ""
//                customDump(error, to: &errorDump, indent: 4)
                runtimeWarn(
                  """
                  An "EffectTask.run" returned from "\(fileID):\(line)" threw an unhandled error. …

                  \(error)

                  All non-cancellation errors must be explicitly handled via the "catch" parameter \
                  on "EffectTask.run", or via a "do" block.
                  """,
                  file: file,
                  line: line
                )
              #endif
              return
            }
            await handler(error, send)
          }
      }
    )
  }

  /// Creates an effect that executes some work in the real world that doesn't need to feed data
  /// back into the store. If an error is thrown, the effect will complete and the error will be
  /// ignored.
  ///
  /// This effect is handy for executing some asynchronous work that your feature doesn't need to
  /// react to. One such example is analytics:
  ///
  /// ```swift
  /// case .buttonTapped:
  ///   return .fireAndForget {
  ///     try self.analytics.track("Button Tapped")
  ///   }
  /// ```
  ///
  /// The closure provided to ``fireAndForget(priority:_:)`` is allowed to throw, and any error
  /// thrown will be ignored.
  ///
  /// - Parameters:
  ///   - priority: Priority of the underlying task. If `nil`, the priority will come from
  ///     `Task.currentPriority`.
  ///   - work: A closure encapsulating some work to execute in the real world.
  /// - Returns: An effect.
  static func fireAndForget(
    priority: TaskPriority? = nil,
    _ work: @escaping @Sendable () async throws -> Void
  ) -> Self {
    Self.run(priority: priority) { _ in try? await work() }
  }
}

/// A type that can send actions back into the system when used from
/// ``EffectPublisher/run(priority:operation:catch:file:fileID:line:)``.
///
/// This type implements [`callAsFunction`][callAsFunction] so that you invoke it as a function
/// rather than calling methods on it:
///
/// ```swift
/// return .run { send in
///   send(.started)
///   defer { send(.finished) }
///   for await event in self.events {
///     send(.event(event))
///   }
/// }
/// ```
///
/// You can also send actions with animation:
///
/// ```swift
/// send(.started, animation: .spring())
/// defer { send(.finished, animation: .default) }
/// ```
///
/// See ``EffectPublisher/run(priority:operation:catch:file:fileID:line:)`` for more information on how to
/// use this value to construct effects that can emit any number of times in an asynchronous
/// context.
///
/// [callAsFunction]: https://docs.swift.org/swift-book/ReferenceManual/Declarations.html#ID622
@MainActor
struct Send<Action> {
  let send: @MainActor (Action) -> Void

  init(send: @escaping @MainActor (Action) -> Void) {
    self.send = send
  }

  /// Sends an action back into the system from an effect.
  ///
  /// - Parameter action: An action.
  func callAsFunction(_ action: Action) {
    guard !Task.isCancelled else { return }
    self.send(action)
  }
}

// MARK: - Composing Effects

extension EffectPublisher {
  /// Merges a variadic list of effects together into a single effect, which runs the effects at the
  /// same time.
  ///
  /// - Parameter effects: A list of effects.
  /// - Returns: A new effect
  @inlinable
  static func merge(_ effects: Self...) -> Self {
    Self.merge(effects)
  }

  /// Merges a sequence of effects together into a single effect, which runs the effects at the same
  /// time.
  ///
  /// - Parameter effects: A sequence of effects.
  /// - Returns: A new effect
  @inlinable
  static func merge<S: Sequence>(_ effects: S) -> Self where S.Element == Self {
    effects.reduce(.none) { $0.merge(with: $1) }
  }

  /// Merges this effect and another into a single effect that runs both at the same time.
  ///
  /// - Parameter other: Another effect.
  /// - Returns: An effect that runs this effect and the other at the same time.
  @inlinable
  func merge(with other: Self) -> Self {
    switch (self.operation, other.operation) {
    case (_, .none):
      return self
    case (.none, _):
      return other
    case (.publisher, .publisher), (.run, .publisher), (.publisher, .run):
      return Self(operation: .publisher(Publishers.Merge(self, other).eraseToAnyPublisher()))
    case let (.run(lhsPriority, lhsOperation), .run(rhsPriority, rhsOperation)):
      return Self(
        operation: .run { send in
          await withTaskGroup(of: Void.self) { group in
            group.addTask(priority: lhsPriority) {
              await lhsOperation(send)
            }
            group.addTask(priority: rhsPriority) {
              await rhsOperation(send)
            }
          }
        }
      )
    }
  }

  /// Concatenates a variadic list of effects together into a single effect, which runs the effects
  /// one after the other.
  ///
  /// - Parameter effects: A variadic list of effects.
  /// - Returns: A new effect
  @inlinable
  static func concatenate(_ effects: Self...) -> Self {
    Self.concatenate(effects)
  }

  /// Concatenates a collection of effects together into a single effect, which runs the effects one
  /// after the other.
  ///
  /// - Parameter effects: A collection of effects.
  /// - Returns: A new effect
  @inlinable
  static func concatenate<C: Collection>(_ effects: C) -> Self where C.Element == Self {
    effects.reduce(.none) { $0.concatenate(with: $1) }
  }

  /// Concatenates this effect and another into a single effect that first runs this effect, and
  /// after it completes or is cancelled, runs the other.
  ///
  /// - Parameter other: Another effect.
  /// - Returns: An effect that runs this effect, and after it completes or is cancelled, runs the
  ///   other.
  @inlinable
  @_disfavoredOverload
  func concatenate(with other: Self) -> Self {
    switch (self.operation, other.operation) {
    case (_, .none):
      return self
    case (.none, _):
      return other
    case (.publisher, .publisher), (.run, .publisher), (.publisher, .run):
      return Self(
        operation: .publisher(
          Publishers.Concatenate(prefix: self, suffix: other).eraseToAnyPublisher()
        )
      )
    case let (.run(lhsPriority, lhsOperation), .run(rhsPriority, rhsOperation)):
      return Self(
        operation: .run { send in
          if let lhsPriority = lhsPriority {
            await Task(priority: lhsPriority) { await lhsOperation(send) }.cancellableValue
          } else {
            await lhsOperation(send)
          }
          if let rhsPriority = rhsPriority {
            await Task(priority: rhsPriority) { await rhsOperation(send) }.cancellableValue
          } else {
            await rhsOperation(send)
          }
        }
      )
    }
  }

  /// Transforms all elements from the upstream effect with a provided closure.
  ///
  /// - Parameter transform: A closure that transforms the upstream effect's action to a new action.
  /// - Returns: A publisher that uses the provided closure to map elements from the upstream effect
  ///   to new elements that it then publishes.
  @inlinable
  func map<T>(_ transform: @escaping (Action) -> T) -> EffectPublisher<T, Failure> {
    switch self.operation {
    case .none:
      return .none
    case let .publisher(publisher):
      let transform = { action in
         transform(action)
      }
      return .init(operation: .publisher(publisher.map(transform).eraseToAnyPublisher()))
    case let .run(priority, operation):
      return .init(
        operation: .run(priority) { send in
          await operation(
            Send { action in
              send(transform(action))
            }
          )
        }
      )
    }
  }
}
