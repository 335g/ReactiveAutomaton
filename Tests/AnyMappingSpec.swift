//
//  AnyMappingSpec.swift
//  ReactiveAutomaton
//
//  Created by Yasuhiro Inami on 2016-06-02.
//  Copyright © 2016 Yasuhiro Inami. All rights reserved.
//

import Result
import ReactiveCocoa
import ReactiveAutomaton
import Quick
import Nimble

/// Tests for `anyState`/`anyInput` (predicate functions).
class AnyMappingSpec: QuickSpec
{
    override func spec()
    {
        typealias Automaton = ReactiveAutomaton.Automaton<MyState, MyInput>

        let (signal, observer) = Signal<MyInput, NoError>.pipe()
        var automaton: Automaton?
        var lastReply: Reply<MyState, MyInput>?

        describe("`anyState`/`anyInput` mapping") {

            beforeEach {
                let mappings: [Automaton.Mapping] = [
                    .Input0 | any => .State1,
                    any     | .State1 => .State2
                ]

                automaton = Automaton(state: .State0, input: signal, mapping: concat(mappings))

                automaton?.replies.observeNext { reply in
                    lastReply = reply
                }

                lastReply = nil
            }

            it("`anyState`/`anyInput` succeeds") {
                expect(automaton?.state.value) == .State0
                expect(lastReply).to(beNil())

                // try any input (fails)
                observer.sendNext(.Input2)

                expect(lastReply?.input) == .Input2
                expect(lastReply?.fromState) == .State0
                expect(lastReply?.toState).to(beNil())
                expect(automaton?.state.value) == .State0

                // try `.Login` from any state
                observer.sendNext(.Input0)

                expect(lastReply?.input) == .Input0
                expect(lastReply?.fromState) == .State0
                expect(lastReply?.toState) == .State1
                expect(automaton?.state.value) == .State1

                // try any input
                observer.sendNext(.Input2)

                expect(lastReply?.input) == .Input2
                expect(lastReply?.fromState) == .State1
                expect(lastReply?.toState) == .State2
                expect(automaton?.state.value) == .State2
            }

        }
    }
}
