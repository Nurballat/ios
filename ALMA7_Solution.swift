// Station ALMA-7: Rescue Protocol

// ===== STARTER CODE (not modified) =====

typealias Reading = (sensor: String, value: Int)

func splitOnce(_ line: String, by separator: Character) -> (String, String)? {
    guard let index = line.firstIndex(of: separator) else { return nil }
    let left = String(line[..<index])
    let right = String(line[line.index(after: index)...])
    return (left, right)
}

let rawLog = [
    "O2:87", "TEMP:-12", "O2:9x", "PRESS:101", "TEMP:abc", "O2:",
    "RAD:3", "O2:64", ":55", "TEMP:31", "PRESS:98", "O2:71",
    "RAD:-1", "TEMP:4", "PRESS:1o2", "O2:90"
]

class Tank {
    var level: Int
    init(level: Int) { self.level = level }
}

class Module {
    let name: String
    var oxygenTank: Tank?
    init(name: String, oxygenTank: Tank?) {
        self.name = name
        self.oxygenTank = oxygenTank
    }
}

class CrewMember {
    let name: String
    let role: String
    let priority: Int
    var module: Module?
    init(name: String, role: String, priority: Int, module: Module?) {
        self.name = name
        self.role = role
        self.priority = priority
        self.module = module
    }
}

let lab  = Module(name: "Lab",  oxygenTank: Tank(level: 40))
let hab  = Module(name: "Hab",  oxygenTank: Tank(level: 12))
let dock = Module(name: "Dock", oxygenTank: nil)

let crew = [
    CrewMember(name: "Timur",   role: "Engineer",  priority: 3, module: lab),
    CrewMember(name: "Dana",    role: "Scientist", priority: 4, module: dock),
    CrewMember(name: "Aigerim", role: "Commander", priority: 1, module: hab),
    CrewMember(name: "Nurlan",  role: "Pilot",     priority: 2, module: nil)
]

var roster: [String: CrewMember] = [:]
for member in crew { roster[member.name] = member }

print("ALMA-7 systems online: \(rawLog.count) log lines, \(crew.count) crew members.")

// ===== END OF STARTER CODE =====


// Level 1

func parseReading(_ raw: String) -> Reading? {
    guard let (left, right) = splitOnce(raw, by: ":"),
          !left.isEmpty,
          let value = Int(right),
          value >= 0 || left == "TEMP"
    else { return nil }
    return (sensor: left, value: value)
}

print(parseReading("O2:87") as Any)
print(parseReading("TEMP:-12") as Any)
print(parseReading("RAD:-1") as Any)
print(parseReading(":55") as Any)

func parseLog(_ lines: [String]) -> (valid: [Reading], invalidCount: Int) {
    var valid: [Reading] = []
    var invalidCount = 0
    for line in lines {
        if let reading = parseReading(line) {
            valid.append(reading)
        } else {
            invalidCount += 1
        }
    }
    return (valid, invalidCount)
}

let logResult = parseLog(rawLog)
print(logResult)

let A = logResult.invalidCount


// Level 2

func select(_ readings: [Reading], where isIncluded: (Reading) -> Bool) -> [Reading] {
    var result: [Reading] = []
    for reading in readings {
        if isIncluded(reading) {
            result.append(reading)
        }
    }
    return result
}

func values(of readings: [Reading]) -> [Int] {
    var result: [Int] = []
    for reading in readings {
        result.append(reading.value)
    }
    return result
}

let o2Readings = select(logResult.valid) { $0.sensor == "O2" }
let o2Values = values(of: o2Readings)
print(o2Readings)
print(o2Values)

func stats(of values: [Int]) -> (min: Int, max: Int, average: Double)? {
    guard let first = values.first else { return nil }
    var minVal = first
    var maxVal = first
    var sum = 0
    for v in values {
        if v < minVal { minVal = v }
        if v > maxVal { maxVal = v }
        sum += v
    }
    let average = Double(sum) / Double(values.count)
    return (minVal, maxVal, average)
}

func stats(_ values: Int...) -> (min: Int, max: Int, average: Double)? {
    stats(of: values)
}

print(stats(3, 8, 1) as Any)
print(stats() as Any)

let o2Stats = stats(of: o2Values)
let B = Int(o2Stats?.average ?? 0)
print(o2Stats as Any)

// closure ladder, sorting readings by value descending
func readingsEqual(_ a: [Reading], _ b: [Reading]) -> Bool {
    guard a.count == b.count else { return false }
    for i in 0..<a.count {
        if a[i].sensor != b[i].sensor || a[i].value != b[i].value { return false }
    }
    return true
}

let sortedFull = logResult.valid.sorted(by: { (a: Reading, b: Reading) -> Bool in
    return a.value > b.value
})
let sortedInferred = logResult.valid.sorted(by: { (a, b) -> Bool in
    return a.value > b.value
})
let sortedImplicitReturn = logResult.valid.sorted(by: { (a, b) in
    a.value > b.value
})
let sortedShorthand = logResult.valid.sorted(by: { $0.value > $1.value })
let sortedTrailing = logResult.valid.sorted { $0.value > $1.value }

let allSortsMatch = readingsEqual(sortedFull, sortedInferred)
    && readingsEqual(sortedFull, sortedImplicitReturn)
    && readingsEqual(sortedFull, sortedShorthand)
    && readingsEqual(sortedFull, sortedTrailing)

print(allSortsMatch)
print(sortedFull)


// Level 3

func heatUp(_ t: Int) -> Int { return t + 5 }
func coolDown(_ t: Int) -> Int { return t - 3 }
func hold(_ t: Int) -> Int { return t }

func chooseProtocol(for temp: Int) -> (Int) -> Int {
    if temp < 18 { return heatUp }
    if temp > 24 { return coolDown }
    return hold
}

print(chooseProtocol(for: 10)(10))
print(chooseProtocol(for: 30)(30))

func runUntilStable(from start: Int, maxSteps: Int = 10) -> (finalTemp: Int, steps: Int, isStable: Bool) {
    var temp = start
    var steps = 0
    while (temp < 18 || temp > 24) && steps < maxSteps {
        let apply = chooseProtocol(for: temp)
        temp = apply(temp)
        steps += 1
    }
    let stable = temp >= 18 && temp <= 24
    return (temp, steps, stable)
}

print(runUntilStable(from: 31))
print(runUntilStable(from: -100, maxSteps: 5))

let tempValues = values(of: select(logResult.valid) { $0.sensor == "TEMP" })
let tempStats = stats(of: tempValues)
let lowestTemp = tempStats?.min ?? 0
let C = runUntilStable(from: lowestTemp).steps
print(lowestTemp, C)


// Level 4

func oxygenLevel(of member: CrewMember) -> Int? {
    return member.module?.oxygenTank?.level
}

print(oxygenLevel(of: roster["Timur"]!) as Any)
print(oxygenLevel(of: roster["Dana"]!) as Any)

func status(of member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        let location = member.module?.name ?? "open space"
        return "\(member.name): no data (\(location))"
    }
    let state = level < 20 ? "CRITICAL" : "OK"
    return "\(member.name): \(level)% \(state)"
}

for member in crew {
    print(status(of: member))
}

@discardableResult
func transferOxygen(from source: inout Int, to target: inout Int, amount: Int) -> Int {
    guard amount > 0 else { return 0 }
    let maxFromSource = min(amount, source)
    let maxToTarget = min(maxFromSource, 100 - target)
    let actualAmount = max(maxToTarget, 0)
    source -= actualAmount
    target += actualAmount
    return actualAmount
}

var labOxygen = lab.oxygenTank?.level ?? 0
var habOxygen = hab.oxygenTank?.level ?? 0
let transferred = transferOxygen(from: &labOxygen, to: &habOxygen, amount: 30)
lab.oxygenTank?.level = labOxygen
hab.oxygenTank?.level = habOxygen
print(transferred, labOxygen, habOxygen)

var testSource = 50
var testTarget = 80
print(transferOxygen(from: &testSource, to: &testTarget, amount: -10))

let D = habOxygen

func evacuationOrder(_ names: String..., roster: [String: CrewMember]) -> [String] {
    var found: [CrewMember] = []
    for name in names {
        guard let member = roster[name] else {
            print("Unknown crew member: \(name)")
            continue
        }
        found.append(member)
    }
    let sortedFound = found.sorted { $0.priority < $1.priority }
    var result: [String] = []
    for member in sortedFound {
        result.append(member.name)
    }
    return result
}

print(evacuationOrder("Dana", "Ghost", "Aigerim", "Timur", roster: roster))
print(evacuationOrder("Nurlan", "Aigerim", roster: roster))


// Level 5

/*
Original code had a few problems:
- member.module! crashes for Nurlan, whose module is nil
- .oxygenTank! crashes for Dana, since Dock has no tank
- oxygenLevel(of: member)! crashes for anyone with no oxygen data
- result! crashes if nobody is critical
- logic bug: the loop doesn't stop at the first critical member, it keeps
  overwriting result, so with more than one critical member it would
  actually return the last one, not the first
*/

func reportOxygen(for member: CrewMember) -> String {
    guard let tank = member.module?.oxygenTank else {
        return "\(member.name): no tank data"
    }
    return "\(member.name): \(tank.level)%"
}

func firstCritical(in crew: [CrewMember]) -> String? {
    for member in crew {
        if let level = oxygenLevel(of: member), level < 20 {
            return member.name
        }
    }
    return nil
}

print(reportOxygen(for: roster["Timur"]!))
print(reportOxygen(for: roster["Dana"]!))

// test proving the logic bug is fixed: two critical members, first one should win
let testCrew = [
    CrewMember(name: "TestCrew1", role: "Test", priority: 5, module: Module(name: "TestMod1", oxygenTank: Tank(level: 10))),
    CrewMember(name: "TestCrew2", role: "Test", priority: 6, module: Module(name: "TestMod2", oxygenTank: Tank(level: 5)))
]
print(firstCritical(in: testCrew) as Any)


// Finale

let launchCode = "\(A)-\(B)-\(C)-\(D)"
print("LAUNCH CODE: \(launchCode)")


// Bonus

func makeAlarm(threshold: Int) -> (Int) -> Bool {
    var count = 0
    return { level in
        if level < threshold {
            count += 1
            print("Alarm #\(count)")
            return true
        }
        return false
    }
}

let alarm = makeAlarm(threshold: 20)
print(alarm(12))
print(alarm(40))
print(alarm(5))


// Defense questions
/*
1. guard let exits the current scope in its else branch, and the unwrapped
   value stays usable for the rest of the function, not just inside a block
   like with if let. Example: status(of:) would need extra nesting if
   written with if let instead of guard let.

2. Int... only works when you write individual values (or nothing) directly
   in the call. Swift doesn't automatically spread an existing array into a
   variadic argument list, even though internally the variadic parameter
   becomes an array.

3. Two inout parameters can't point to the same variable in one call, Swift's
   exclusivity rule blocks it, since the function could read a half-mutated
   value mid-call.

4. oxygenLevel(of:) returns Int?, so ?? needs an Int on the right side, not a
   String like "no data". Types have to match.

5. (Int) -> (Int) -> Int. chooseProtocol takes an Int and returns another
   function, and that returned function takes an Int and returns an Int.

Bonus: count is captured by reference in a heap-allocated box that the
returned closure holds onto, so it survives after makeAlarm's own stack
frame is gone.
*/
