
.. .. todolist::

============
Introduction
============

Scope
=====

This guide is intended to act as an example led introduction to the
Non-Uniform Memory Access (NUMA) description
available in the ACPI 6.3 specification.

NUMA descriptions are about describing the relative *distance*
between components in shared memory computer.  As we shall see, this
concept of distance has a complex definition in a modern system.

Intended Audience
=================

Whilst the content may be of interest to userspace application developers,
to understand *what* is described, the primary audience is:

* Firmware developers who want to know how to describe their systems
* OS developers who wish to understand better what the description they are
  seeing actually means.

Document Conventions
====================

A few conventions are adopted to aid readability.

* Reserved fields are not shown in examples - implement them as per the ACPI
  specification.

References
==========

There are numerous good references on general NUMA concepts 

* Linux kernel documentation https://www.kernel.org/doc/html/v4.20/vm/numa.html

* ACPI Specification 6.3 http://www.uefi.org

* UEFI Specification 2.8 http://www.uefi.org



Changes since ACPI 6.2
======================

A major focus of the ACPI 6.3 cycle was to enhance the existing specification
to better support Heterogeneous systems.  Key aspects introduced were:

* Generic Initiators
* HMAT Changes
* Specific Purpose Memory (also defined in UEFI 2.8)

Generic Initiators
******************

A Generic Initiator (GI) is a non-host-processor initiator of memory operations.
Note, that by non-host-processor we mean one that is not responsible for running
normal applications or parts of the operating system.

Prior to ACPI 6.3, these were typically only described via DSDT with _PXM
(See :cite:`2019:ACPI` Section 6.2.14 _PXM (Proximity))
being used to associate them with Proximity Domains defined in SRAT
(See :cite:`2019:ACPI` Section 5.2.16 System Resource Affinity Table (SRAT)).

.. todo:: Look at reference styles as this is a bit ugly.


These, SRAT defined, Proximity Domains primarily included Memory
and/or Processors. This limitation prevented accurate description of systems
where the characteristics of accesses from these GIs were not the same as
from the existing domains.  All that could be done was to put them into the
*best available* domain.  With the advent of accelerators connected to complex
coherent interconnects, this was no longer good enough.

These are described in more detail in :numref:`gasect`.  

HMAT Changes
************

Several minor changes in HMAT contribute to improving the ability to
describe the inter-domain properties in a consistent and useful fashion.

As the HMAT table was little used prior to ACPI 6.3, we shall not focus
on these changes, but instead describe the current situation.

Specific Purpose Memory
***********************

This concept is not directly related to NUMA systems, but is important
to the sort of complex NUMA system ACPI 6.3 allows you to describe, so
we will include a brief description here.

The UEFI specification, :cite:`2019:UEFI` Section 7.2,
defines a range of different memory types, according
to their different operating attributes / characteristics.  For example,
Linux considers any memory to be *normal memory* if it is:

* Cacheable with a Write Back Policy
* Not non-volatile and hence not described in the NFIT ACPI table.

Some memory in a system, whilst functionally capable of being used as normal
Operating System managed memory, may be intended for particular use cases.
Examples of this include coherent memory located at a GPU, or a large memory
intended for use for an in-memory database.

These memories may have characteristics that may make them unsuitable for
general usage include:

* Large latencies,
* Different reliability characteristics to main memory.

Some operating systems, including Linux will, by default, allocate some
data structures evenly across all memory proximity domains in the system.
One use of SPM may be to mark some regions of memory as being unsuitable
for this use, thus keeping them available for the intended use.

ACPI 6.3 does not specify *how* this information will be used as that is
something that may take considerable discussion and experimentation to
pin down.  Whilst an interesting topic to explore, we are not intending
to cover it any further in this version of this document.

Why does an Operating System Care?
==================================

There are a lot of aspects to this - we need to consider
some of them here to justify the design of the ACPI tables.
In particular we will aim to highlight when the way the
operating system uses this information, may affect the way
in which a firmware decides to present it.

First we shall introduce some basic concepts.

ACPI NUMA Description - Major Elements
======================================

There are many possible ways of describing the topology of
a computer system.  The ACPI NUMA description takes some
simple concepts on to which complex topologies may be mapped
in a useful fashion.  The most fundamental concept is that
of a Proximity Domain or NUMA node.

Before considering specific examples, let us look at a somewhat
more accurate real system, :numref:`figsimple-2p`. 

.. _figsimple-2p:
.. figure:: typical-2p.*
    :figclass: align-center

    A Simplified 2 Socket Server with a reasonable NUMA node assignment.

This configuration
contains a number of CPU cores as well as PCIe connected peripherals.
For the majority of this document, single CPU cores per node will be
shown. This is sufficient to convey the important points and reduces
repetition in the examples.
Similarly, peripherals will only be introduced when we consider
their NUMA representation.

NUMA Nodes
**********

A NUMA node consists of a group of elements of the system. These
may include:

* Processors
* Memory
* Peripheral Buses
* Networking devices, storage controllers
* Chipset

These elements can be considered to be in a single node if there is
no benefit in describing them separately.  The benefits that may
be derived from separating elements into different nodes will be
addressed later.

This lack of benefit, typically means that no information can be provided that would
lead to a particular placement or usage decision by the Operating System.
Any given implementation may decide to make further simplifying
assumptions suitable for its targeted application area, perhaps deciding
not to differentiate between memories that are *similar* in characteristics.

Simple cases of such information include

* Bandwidth between an initiator on a NUMA node and memory on a different NUMA node.
* Latency between am initiator on a NUMA node and memory on a different NUMA node.
* Bandwidth and latency between a user of memory and the memory found in the
  same NUMA node.
* Different caches available in front of the possible memory choices.
* The older concept of NUMA distance, a relative measure of the
  memory latency between different NUMA nodes.

As we shall see, there can be more complex reasons to describe separate NUMA nodes.
Some of these only become apparent when we consider how the Operating System
makes use of the memory.

What we mean by memory
**********************

A modern system contains a number of different types of memory with different
access characteristics and restrictions.  For example, we have DDR attached
to memory controllers on an SoC as well as large memories closely coupled to GPUs
which may not be coherently cached by the CPU.  Not all of these
memories are described in the NUMA description that ACPI 6.3 provides.

It is important to note that the ACPI 6.3 specification's
NUMA description is concerned only with memory which may be used for
general purpose allocations.  This means that, for the memory in question:

* Cache coherency must be maintained so that different initiators
  within the system obtain the latest version of what is memory, without any
  software interactions.

* Atomic operations consistent with those of the relevant CPU architecture must
  be supported.

Another way of looking at this, is that, other than bandwidth and latency characteristics,
this memory must behave the same as the system's RAM. That the memory
may be used for general purpose allocations, from the point of view of correct operation,
does not mean that it is suitable for such use when performance is considered.
The Specific Purpose Memory attribute is intended to provide information
to the operating system on whether such memory is suitable / intended for
such general purpose use.

Unrolling the topology
**********************

The ACPI 6.3 description of the NUMA properties of the system may be thought of
as unrolling each path across the interconnect and system topology, so as to be
able to describe end to end properties between any two points.

.. _figsimple:
.. figure:: simple.*
    :figclass: align-center

    A very simple NUMA topology.

:numref:`figsimple` shows a very simple NUMA topology with two single CPU SoCs, each of
which has local DDR memory, and the interconnect between them.
The ACPI NUMA representation simplifies this topology somewhat in order to
make it easier to describe and use.
This can be thought of as an *unrolling* process. An example of the results
of this is shown in :numref:`figunrolled`.

.. _figunrolled:
.. figure:: Unrolling.*
    :figclass: align-center

    An *unrolled* representation of the NUMA topology.

The intermediate elements in this unrolling, are only of interest for the restrictions that
they may place upon the link between the requester (here always a CPU) and the memory it is
working with.  This means that ACPI only ever considers the *aggregate* properties all the
way between the initiator and memory.

Combining elements into nodes
*****************************

Now, at first glance, it might seem to make sense to have 4 separate nodes for the simple
topology seen in :numref:`figsimple`, one for each of the CPUs and one for each of the Memories.
This would correspond to the underlying physical layout and would be a correct description.
However, ACPI allows the properties between an initiator
(here a CPU) and memory to be described even if they are within the same NUMA node.

This allows us to create NUMA nodes as shown in :numref:`figsimplenodes`. 
:numref:`figsimplenodesunrolled` show how these NUMA nodes map to the unrolled representation.

.. _figsimplenodes:
.. figure:: simplenodes.*
    :figclass: align-center

    NUMA nodes for the simple topology.

.. _figsimplenodesunrolled:
.. figure:: simplenodesunrolled.*
    :figclass: align-center

    The nodes shown in :numref:`figsimplenodes` in their unrolled representation.

Why would we want to do this combining?
***************************************

Some of the topology descriptions, that we will shortly come onto, use dense matrices to represent
the characteristics of these nodes.   It is therefore useful to combine potential nodes as we
have done here as long as there is no loss of representative power.

The concept of *local memory* is also used by operating systems to provide a simple, best
choice, when trying to locate data near to the initiator making use of it.  It is defined
as being that memory which is the best choice for a particular initiator.  Whilst 
co-locating memory and initiator in a particular domain makes the choice obvious, Operating
Systems will often fall back to a search of Proximity Domains so as to be provide a good
answer for initiators that are in nodes without local memory. In Linux these were termed
*Memoryless Nodes*.

How Operating Systems use NUMA Information
==========================================

Linux
*****

For each node containing memory, Linux manages the memory separately, this means:

* Separate free page lists
* Separate in-use page lists
* Separate usage statistics

In Linux, there is another level of subdividing done within each NUMA node.  This subdivision
is into Memory Zones.  Each Zone represents memory that shares certain
characteristic which restrict what allocations it may be used to satisfy.
For example, ZONE_DMA is memory suitable for DMA access from initiators with limited address
range support, whilst ZONE_MOVABLE is used to prevent allocations that cannot be moved,
thus allowing for the migration needed for hot removing memory.

For each of these zones, within each NUMA node, the Linux Kernel maintains a fallback list.
The ordering is such that a allocations first fallback to the same zone on other numa nodes
(ordered by NUMA distance) and only once the zone is full across all nodes do the fallback
to other zones on the local node.  This choice was made to preserve those zones which can
be used for any allocation, but which are a limited resource.

Subject to there being space, by default, Linux always attempts to allocate memory
from the NUMA node from which the request originates - the so-called 'local' node
(typically the node containing the CPU running the allocation call).
There are exceptions to this.  One of the biggest is that
it will allocate memory associated with a particular hardware device such as a network
card, on the NUMA node in which the network card is found. (note this is only true in
well constructed drivers).

The scheduler, which is responsible for deciding which processor tasks are running on,
uses the NUMA information to try to minimize the migration of processes to other NUMA
nodes as this will put a large load on the system interconnect.

The kernel provides user-space applications with the ability to set a mask on which NUMA
nodes a process is limited to, and which nodes it memory will be allocated from. 

Advance topics such as NUMA balancing are out of the scope of this particular document.

Windows
*******

Some information on Window's use of NUMA characteristics may be found at
https://docs.microsoft.com/en-us/windows/desktop/ProcThread/numa-support


           
