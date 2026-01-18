
# Questline: Sensors

Multi-step processes just to craft some logic gates? Yes please!

## Sensor Linker

### Text

It is the beginning of the sensor questline; it will be required for almost any sensor.

Press **aux1 + any click/tap** with the sensor tool on a sensor to link that tool to the sensor.
Then, you can **right-click** with the tool on a sensor and set the name of the link (usually "A" or "B").
You can **left-click** with the tool on a sensor and automatically use the name you got from **right-clicking**.
When you **left-click** a node that is already linked, it will unlink it.

### Meta

Requires: Blast Furnace

## Logic Gates

### Text

They are machines that turn themselves off or on, depending on the states of other machines.
You have to use the sensor linker with logic gates:

* You have to make an "A" link as the 1st input
* Most of the time, you have to make a "B" link as your 2nd input

All logic gates run once every 0.25 seconds; this may be referred to as a "switching station subtick".

When you have multiple logic gates in a chain, there are two types of connections:

* **"slow" connections** — where each logic gate has to wait 0.25 s to execute
* **"fast" connections** — where a sequence of logic gates executes instantly

They are dependent on the order in which the switching station executes the logic gates. Switching from a fast connection to a slow one, or the other way around, may involve simply switching the direction of the wire or changing how they are connected to each other.

You can make a computer with these. I would strongly recommend not doing that. If you want to, submit your code optimizations to skyblock zero logic gates with a pull request.

Descriptions of each logic gate, if you are unfamiliar with them:
Buffer gate — It will copy the state of the machine linked in "A"; if it is on, it will be on; if it is off, it will be off
NOT gate — If a machine in link "A" is off, it will be on; if a machine in link "A" is on, it will be off
OR gate — If a machine in link "A" is on, or a machine in link "B" is on, it will be on; otherwise, it will be off
AND gate — Both machines in links "A" and "B" have to be on for the logic gate to be on
XOR gate — Like the OR gate, but if both machines are on, it will turn off
XNOR gate — Like the XOR gate, but passed through a NOT gate
NOR gate — Like the OR gate, but passed through a NOT gate
NAND gate — Like the AND gate, but passed through a NOT gate

You can complete this quest by crafting the buffer gate.

### Meta

Requires: Sensor Linker

## Machine Controller

### Text

It is a machine that sets the state of multiple machines according to another chosen machine.

You have to use the sensor linker with machine controllers:

* Link "A" determines the machine whose state should be copied to all the machines in link "B"

Example:
The machine at link "A" is off, so all the machines in link "B" are turned off

### Meta

Requires: Sensor Linker

## Delayer

### Text

The Delayer is not a machine, but rather a node that turns on after a selected amount of time.
It uses node timers, so it may not work when you aren't near it (somewhere around 48 nodes away). However, it will work if it is force-loaded in some way. So it may or may not work near machines—test it yourself :D.

### Meta

Requires: Sensor Linker

## Light Sensor

### Text

Finally! A sensor in the "Sensors" questline!

It senses light; depending on the condition (see the UI), it will turn on; otherwise, it will turn off.

Link "A" determines which position to test.

### Meta

Requires: Sensor Linker

## Node Sensor

### Text

Link "A" determines which node to check.

It will turn on if the node at link "A" matches what is shown in the UI.

### Meta

Requires: Sensor Linker

## Item Sensor

### Text

Now... this one is a little tricky.

Link "A" should be a pipeworks-compatible storage.
It will check if it can insert an item into that storage; if yes, it will turn on.

In most machines, the item count that you put into this sensor won't matter.

### Meta

Requires: Sensor Linker

## Switches

### Text

They are like connectors, but they don't do anything to a power network.
You can turn them on or off.

### Meta

Requires: Sensor Linker
