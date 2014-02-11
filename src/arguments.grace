#pragma ClassMethods

dialect "typed"

import "mgcollections" as coll
import "sys" as sys

// Exception raised if a malformed argument list is given.
def ArgumentException is public = Exception.refine("ArgumentException")

// Used internally to indicate the absence of a short hand.
def noShortHand = object {}

type ShortHand = String | singleton(noShortHand)

type Command = {

    // Register a new flag.
    flag(name : String) description(description : String) -> Self

    // Register a new flag with a short hand.
    flag(name : String) shortHand(shortHand : ShortHand)
        description(description : String) -> Self

    // Register a new option.
    option(name : String, *values : String)
        description(description : String) -> Self

    // Register a new option with a short hand.
    option(name : String, *values : String) shortHand(shortHand : ShortHand)
        description(description : String) -> Self

    // Parse the argument list using the registered argument types.
    parseList(args : List<String>)

}

type Builder = Command & {

    // Register a new command.
    command(cmd : String) -> Self

    // Parse the system arguments using the registered argument types.
    parseArgv

}

// Builds objects for registering flags and options for a command.
class builder' -> Builder' is confidential {

    type ShortHand = String | singleton(noShortHand)

    type Flag is confidential = {
        name -> String
        shortHand -> ShortHand
        description -> String
    }

    class flag(name' : String, shortHand' : ShortHand,
               description' : String) -> Flag is confidential {
        def name : String is public = name'
        def shortHand : ShortHand is public = shortHand'
        def description : String is public = description'
    }

    type Option is confidential = Flag & type {
        values -> List<String>
    }

    class option(name : String, *values' : String, shortHand : ShortHand,
                 description : String) -> Option is confidential {
        inherits flag(name, shortHand, description)
        def values : List<String> is public = values'
    }

    def args : List<Flag> = []

    method flag(name : String) description(description: String) {
        flag(name) shortHand(noShortHand) description(description)
    }

    method flag(name : String) shortHand(shortHand : ShortHand)
           description(description : String) {
        args.push(flag(name, shortHand, description))
        self
    }

    method option(name : String, *values : String) {
        option(name, *values) shortHand(noShortHand)
    }

    method option(name : String, *values : String)
           shortHand(shortHand : ShortHand)
           description(description : String) {
        args.push(option(name, *values, shortHand, description))
        self
    }

    method helpText -> String {
        var text := ""

        for (args) do { arg ->
            text := "{text}--{arg.name}{showShortHand(arg)} "

            match (arg) case { option : Option ->
                text := "{text}<{option.value}> "
            }

            text := "{text}{arg.description}"
        }

        text
    }

    // Utility for not displaying short hand if it doesn't exist.
    method showShortHand(arg) -> String is confidential {
        if (arg.shortHand == noShortHand) then {
            ""
        } else {
            " -{arg.shortHand}"
        }
    }

    method parseList(argv : List<String>) {
        // TODO
    }

}

class builder {
    inherits builder'

    def cmds = coll.map.new

    method command(name : String) {
        def cmd = builder'
        cmds.put(name, cmd)
        cmd
    }

    method parseArgv {
        parseList(sublist(sys.argv) from(2))
    }

    method parseList(argv : List<String>) {
        def cmd = argv.at(1)
        if (cmd.startsWith("-")) then {
            super.parseList(argv)
        }

        if (cmds.get(cmd)) then {
            cmd.parseList(sublist(argv) from(2))
        }
    }
}

// Sublist utility.
method sublist<T>(list : List<T>)
       from(index : Number) -> List<T> is confidential {
    def result = []
    def len = list.size

    var i := index
    while { i <= len } do {
        result.push(list.at(i)
        i := i + 1
    }

    result
}

