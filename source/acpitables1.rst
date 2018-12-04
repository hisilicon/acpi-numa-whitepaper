.. include:: <isonum.txt>

=====================================
Simple NUMA description
=====================================

We will continue with the simple example we have already introduced in :numref:`figsimple`
and consider how this is represented in the ACPI tables passed from the firmware to the
Operating System.  For this we will use the NUMA node allocations shown in
:numref:`figsimplenodes`.

For now we will consider only boot time information.

Enumerating the NUMA Nodes - System Resource Affinity Table (SRAT)
==================================================================

The System Resource Affinity Table is the boot time description of elements
that make up the NUMA node.  In ACPI a NUMA node is referred to a Proximity Domain.

Like all ACPI tables SRAT starts with some preamble, all of which is
straight forward, so we will skip on to the Static Resource Allocation Structures.

Static Resource Allocation Structure
************************************

This structure takes a number of forms, allowing us to define the various elements that make up
each individual NUMA node.

Processor Affinity Structures
-----------------------------

There are several affinity structure variants depending on how CPUs are identified in the system.
The each carry some additional information but it is not of interest to us here.

* **Processor Local APIC/SAPIC Affinity Structure** APIC ID or SAPIC ID/EID to proximity domain.

* **Processor Local x2APIC Affinity Structure** x2APIC ID to proximity domain.

* **GICC Affinity Structure**  ACPI Processor UID to proximity domain.

Memory Affinity Structures
--------------------------

The Memory Affinity Structure provides an association between memory,
identified via its address range in the systems physical address map,
and the proximity domain in which we wish to represent it.  This structure
also carries some additional information on the memory region:

* Hot-plug - does this region support hot-plug.
* Non-Volatile - is this region served by non volatile memory.

For our example, :numref:`figsimplenodes`, we have two volatile memories to
describe, one within proximity domain 0 and one within proximity domain 1.

Interrupt Translation Service Structures (ITS) Affinity Structure
-----------------------------------------------------------------

This one is mostly out of the scope of this description, but is used to allow an Operating System
to identify what memory is close to an ITS so as to place its management tables and command queue
appropriately.

It may be thought of in a similar way to a generic initiator (see :numref:`gasect`) in that it isn't a processor, but
does make use of memory.

For our example, :numref:`figsimplenodes`, we assume a single ITS in Proximity Domain 0.

So on to the description of our simple topology. Note we have broken the
table up for readability but the following tables will all be concatenated.
In this example the processors are described via the GICC affinity structure,
for other systems they may be described using either the
*Local APIC/SAPIC Affinity Structure* or the
*Processor Local x2APIC Affinity Structure*.

Simple Topology SRAT
********************

.. tabularcolumns:: |p{0.20\linewidth}|>{\centering\arraybackslash}p{0.15\linewidth}|p{0.50\linewidth}|
.. table:: Simple Topology SRAT example - Header
    :widths: 70 55 200

    +--------------------+------------+---------------------------+
    |    Field           |  Value     |   Notes                   |
    +====================+============+===========================+
    | Signature          | SRAT       | Identify Table            |
    +--------------------+------------+---------------------------+
    | Length             | N          |                           |
    +--------------------+------------+---------------------------+
    | Revision           | 3          |                           |
    +--------------------+------------+---------------------------+
    | Checksum           | XXXXXXXX   | See spec                  |
    +--------------------+------------+---------------------------+
    | OEMID              | XXXX       | See spec                  |
    +--------------------+------------+---------------------------+
    | OEM Revision       | XXXX       | See spec                  |
    +--------------------+------------+---------------------------+
    | Creator ID         | XXXX       | See spec                  |
    +--------------------+------------+---------------------------+
    | Creator Revision   | XXXX       | See spec                  |
    +--------------------+------------+---------------------------+

.. tabularcolumns:: |p{0.20\linewidth}|>{\centering\arraybackslash}p{0.15\linewidth}|p{0.50\linewidth}|
.. table:: Simple Topology SRAT example  - Entry 0: Processor 0
    :widths: 70 55 200

    +--------------------+------------+---------------------------+
    |    Field           |  Value     |   Notes                   |
    +====================+============+===========================+
    | Type               | 3          | GICC Affinity Structure   |
    +--------------------+------------+---------------------------+
    | Length             | 18         |                           |
    +--------------------+------------+---------------------------+
    | Proximity Domain   | 0          |                           |
    +--------------------+------------+---------------------------+
    | ACPI Processor UID | XXXXXX     | See spec                  |
    +--------------------+------------+---------------------------+
    | Flags              | 1          | Enable                    |
    +--------------------+------------+---------------------------+
    | Clock Domain       | XXXX       | See spec                  |
    +--------------------+------------+---------------------------+

.. tabularcolumns:: |p{0.20\linewidth}|>{\centering\arraybackslash}p{0.15\linewidth}|p{0.50\linewidth}|
.. table:: Simple Topology SRAT example - Entry 1: Processor 1
    :widths: 70 55 200

    +--------------------+------------+---------------------------+
    |    Field           |  Value     |   Notes                   |
    +====================+============+===========================+
    | Type               | 3          | GICC Affinity Structure   |
    +--------------------+------------+---------------------------+
    | Length             | 18         |                           |
    +--------------------+------------+---------------------------+
    | Proximity Domain   | 1          |                           |
    +--------------------+------------+---------------------------+
    | ACPI Processor UID | XXXXXX     | See spec                  |
    +--------------------+------------+---------------------------+
    | Flags              | 1          | Enable                    |
    +--------------------+------------+---------------------------+
    | Clock Domain       | XXXX       | See spec                  |
    +--------------------+------------+---------------------------+

.. tabularcolumns:: |p{0.20\linewidth}|>{\centering\arraybackslash}p{0.15\linewidth}|p{0.50\linewidth}|
.. table:: Simple Topology SRAT example - Entry 2: Memory 0
    :widths: 70 55 200

    +--------------------+------------+---------------------------+
    |    Field           |  Value     |   Notes                   |
    +====================+============+===========================+
    | Type               | 1          | Memory Affinity Structure |
    +--------------------+------------+---------------------------+
    | length             | 40         |                           |
    +--------------------+------------+---------------------------+
    | Proximity Domain   | 0          |                           |
    +--------------------+------------+---------------------------+
    | Base Address Low   | 0x00000000 | Low 32 bits of start of   |
    |                    |            | address range             |
    |                    |            |                           |
    |                    |            | (Address 0x2_0000_0000)   |
    +--------------------+------------+---------------------------+
    | Base Address High  | 0x00000002 | High 32 bits of start of  |
    |                    |            | address range             |
    +--------------------+------------+---------------------------+
    | Length Low         | 0x00000000 | Low 32 bits of length of  |
    |                    |            | of address range          |
    |                    |            |                           |   
    |                    |            | (Address length = 4G)     |
    +--------------------+------------+---------------------------+
    | Length High        | 0x00000001 | High 32 bits of length of |
    |                    |            | address range             |
    +--------------------+------------+---------------------------+
    | Flags              | 1          | Enabled                   |
    +--------------------+------------+---------------------------+

.. tabularcolumns:: |p{0.20\linewidth}|>{\centering\arraybackslash}p{0.15\linewidth}|p{0.50\linewidth}|
.. table:: Simple Topology SRAT example - Entry 3: Memory 1
    :widths: 70 55 200

    +--------------------+------------+---------------------------+
    |    Field           |  Value     |   Notes                   |
    +====================+============+===========================+
    | Type               | 1          | Memory Affinity Structure |
    +--------------------+------------+---------------------------+
    | length             | 40         |                           |
    +--------------------+------------+---------------------------+
    | Proximity Domain   | 1          |                           |
    +--------------------+------------+---------------------------+
    | Base Address Low   | 0x00000000 | Low 32 bits of start of   |
    |                    |            | address range             |
    |                    |            |                           |
    |                    |            | (Address 0x3_0000_0000)   |
    +--------------------+------------+---------------------------+
    | Base Address High  | 0x00000003 | High 32 bits of start of  |
    |                    |            | address range             |
    +--------------------+------------+---------------------------+
    | Length Low         | 0x00000000 | Low 32 bits of length of  |
    |                    |            | of address range          |
    |                    |            |                           |
    |                    |            | (Address length = 4G)     |
    +--------------------+------------+---------------------------+
    | Length High        | 0x00000001 | High 32 bits of length of |
    |                    |            | address range             |
    +--------------------+------------+---------------------------+
    | Flags              | 1          | Enabled                   |
    +--------------------+------------+---------------------------+

.. tabularcolumns:: |p{0.20\linewidth}|>{\centering\arraybackslash}p{0.15\linewidth}|p{0.50\linewidth}|
.. table:: Simple Topology SRAT example - Entry 4: ITS 0
    :widths: 70 55 200

    +--------------------+------------+---------------------------+
    |    Field           |  Value     |   Notes                   |
    +====================+============+===========================+
    | Type               | 4          | GIC ITS Affinity Structure|
    +--------------------+------------+---------------------------+
    | length             | 12         |                           |
    +--------------------+------------+---------------------------+
    | Proximity Domain   | 0          |                           |
    +--------------------+------------+---------------------------+
    | ITS ID             | XXXXXXXXX  | Match the ITS ID of the   |
    |                    |            | GIC ITS entry in MADT     |
    +--------------------+------------+---------------------------+

It is worth noting at this point that SRAT is the only way of defining
Proximity Domains in ACPI.  They cannot be defined other than at boot
time.  We shall revisit this restriction in :numref:`sechotplug`.

Describing Node Relationship - System Locality Information Table (SLIT)
=======================================================================

The System Locality Information Table provides the first level of description
of the relationships between nodes.  Note that, if the Operating System
is able to interpret it and an HMAT is present, the Operating System is expected
to use the data in HMAT rather than that in SLIT.  It will be
necessary to provide SLIT tables for quite some time as Operating Systems are
not currently fully transferred to HMAT.

After an standard ACPI preamble this table consists of a matrix providing
a measure of *distance* between nodes.

What is this distance?
**********************

Unfortunately the definition of this distance is somewhat vague.
It is defined as the relative latency between nodes.

The special value 10 is used as the local reference value and is always
present on the diagonal. 

A second magic value of 255 is defined as indicating that there is
no path between particular nodes.

Distance values of 0-9 are defined as reserved and have no meaning.
The first value was set at 10 so as to allow for fractional relative
distances, so 1.5\ |times| the distance.

For our example, let us assume that the latency ratio between
local accesses (the DDR connected directly to the processor) and
remote accesses (the DDR connected to the other processor) is 2.
This will give us a SLIT distances of 10 and 20 for the various
paths.

Simple Topology SLIT
********************

.. tabularcolumns:: |p{0.20\linewidth}|>{\centering\arraybackslash}p{0.15\linewidth}|p{0.50\linewidth}|
.. table:: Simple Topology SLIT example
    :widths: 70 55 200

    +--------------------+-----------+----------------------------------+
    |    Field           |  Value    |   Notes                          |
    +====================+===========+==================================+
    | Signature          | SLIT      | Identify Table                   |
    +--------------------+-----------+----------------------------------+
    | Length             | N         |                                  |
    +--------------------+-----------+----------------------------------+
    | Revision           | 1         | See spec                         |
    +--------------------+-----------+----------------------------------+
    | Checksum           | XXXXXXXX  | See spec                         |
    +--------------------+-----------+----------------------------------+
    | OEMID              | XXXX      | See spec                         |
    +--------------------+-----------+----------------------------------+
    | OEM Revision       | XXXX      | See spec                         |
    +--------------------+-----------+----------------------------------+
    | Creator ID         | XXXX      | See spec                         |
    +--------------------+-----------+----------------------------------+
    | Creator Revision   | XXXX      | See spec                         |
    +--------------------+-----------+----------------------------------+
    | Number of System   | 2         | Our total node count.            |
    | Localities         |           | Sets the SLIT matrix dimension   |
    +--------------------+-----------+----------------------------------+
    | Entry[0][0]        | 10        | Node 0 to directly attached DDR  |
    +--------------------+-----------+----------------------------------+
    | Entry[0][1]        | 20        | Node 0 to Node 1 DDR             |
    +--------------------+-----------+----------------------------------+
    | Entry[1][0]        | 20        | Node 1 to Node 0 DDR             |
    +--------------------+-----------+----------------------------------+
    | Entry[1][1]        | 10        | Node 0 to directly attached DDR  |
    +--------------------+-----------+----------------------------------+

Limitations of SLIT
*******************

There is no clear definition of how to measure latency.  For a given
initiator to target, there are many application related factors that will
change the apparent latency.

* Packet size
* Access pattern, random vs sequential
* Other traffic
* Cache effects
* Link bandwidth as this effects the latency if the load is high.
* Any intermediate buffering that would have an effect on latency as
  the load on the link increases.

The HMAT table was introduced to provide some more information to those operating
systems and user-space processes that chose to make use of it. However, it
is worth noting that performance of a memory from stand point of a particular
initiators  is dependent on many factors that are not described by HMAT.

Note that there are some additional restrictions upon SLIT tables applied
by operating systems.  This is considered in :numref:`slitoslimit`.

Heterogenous Memory Attribute Table (HMAT)
==========================================

The Heterogenous Memory Attribute Table was introduced to provide additional
information beyond that provided by SRAT and SLIT.  Some of this we will
deliberately not touch in detail here as it is not relevant to our simple
example and will be introduced later.

Note that this table has changed considerably in the ACPI 6.3 specification.
It is thought that few Operating Systems were making use of the ACPI 6.2
version of this table so we will not consider that here.

For Proximity Domains, as enumerated by SRAT, HMAT describes:

* Memory Attributes

    - memory-side caches
    
    - latency of memory and all levels of memory-side cache

    - bandwidth of memory and all levels of memory-side cache

    - connectivity of memory

Note, HMAT does not define the Proximity Domains; they are defined in SRAT.
However, the introduction of HMAT may lead system designers to chose to
represent a finer grained set of Proximity Domains than they would if the
extra information in HMAT were not to be made available to the Operating System.
This extra level of detail is also reflected in a larger SLIT table, and this
may lead to unwanted complexity, or inefficient use of the memory by a non HMAT
aware Operating System.

Elements of HMAT
****************

As it is an ACPI table, HMAT includes the standard preamble followed by
a series of HMAT Table Structures.  All of these structures are optional
and should only be provided if they deliver information *of use* to the
Operating System in making decisions.  As use-cases are hard to know
in advance, a very broad concept of *useful* should be applied rather
than focusing on any predefined use case.

Preamble
--------

.. tabularcolumns:: |p{0.20\linewidth}|>{\centering\arraybackslash}p{0.15\linewidth}|p{0.50\linewidth}|
.. table:: Heterogenous Memory Attribute Table Preamble example
    :widths: 70 55 200

    +--------------------+-----------+----------------------------------+
    |    Field           |  Value    |   Notes                          |
    +====================+===========+==================================+
    | Signature          | HMAT      | Identify Table                   |
    +--------------------+-----------+----------------------------------+
    | Length             | N         |                                  |
    +--------------------+-----------+----------------------------------+
    | Revision           | 2         |                                  |
    +--------------------+-----------+----------------------------------+
    | Checksum           | XXXXXXXX  | See spec                         |
    +--------------------+-----------+----------------------------------+
    | OEMID              | XXXX      | See spec                         |
    +--------------------+-----------+----------------------------------+
    | OEM Table ID       | XXXX      | See spec                         |
    +--------------------+-----------+----------------------------------+
    | OEM Revision       | XXXX      | See spec                         |
    +--------------------+-----------+----------------------------------+
    | Creator ID         | XXXX      | See spec                         |
    +--------------------+-----------+----------------------------------+
    | Creator Revision   | XXXX      | See spec                         |
    +--------------------+-----------+----------------------------------+

This is followed directly by as many entries as necessary to describe different
NUMA aspects of the system. 

Proximity Domain Attributes Structure
-------------------------------------

Note this structure is effectively new for ACPI 6.3.

This sub structure of HMAT is currently only used as a way to apply flags
to a particular relationship between an initiator domain, which must contain
either a Processor or Generic Initiator, and a memory domain which it may
access.  The only flag present in ACPI 6.3 indicates direct attachment between
the two.  For our simple example, this flag is not relevant so no
Proximity Domain Attributes Structures will be present.  Note that Linux will
use this flag as a hint to *prefer* such memory to other memories which
otherwise have the same characteristics.

System Locality Latency and Bandwidth Information Structure
-----------------------------------------------------------

This structure provides a more detailed version of the Proximity Distance
that has previously been provided by SLIT.

Note that all entries have associated initiator proximity domain and
memory domain allowing the table to be incomplete in cases where only
particular combinations are of interest (not all Proximity Domains will
have memory or initiators - though they will have one or or the other).

What is Latency?
................

The latency is the lowest expected read / write latency between the initiator
and the memory.  It is not defined for a particular type of transfer but
rather is expected to show the best possible value under optimum conditions
for the system.

The format is designed to be extremely flexible, combining a 64 bit base
unit, which is a multiplication factor applied to all the table
entries, with individual 16 bit entries.  The resulting computed value
is in picoseconds.  Entries may be marked as not provided using the special
value 0.

.. math::

    lat[i][j] &= lat_{base} \times lat_{entry}[i][j]


What is Bandwidth?
..................

The bandwidth is the highest expected read / write bandwidth between the
initiator and the memory.  The choice of transfer type should reflect the
optimum choice for this particular pairing.

In a similar fashion to Latency, the format is defined in terms of a shared,
64 bit, base unit and individual 16 bit entries.  The resulting computed value is
in MiB/Second.

.. math::

    bw[i][j] &= bw_{base} \times bw_{entry}[i][j]

Back to our example...

Let us suppose the following characteristics
(node 1 has slightly lower performance DDR than node 0 and the
interconnect is assumed symmetric but has relatively low
bandwidth)

* Latency
    - Node 0 Initiator to Local DDR read latency 90 ns.
    - Node 0 Initiator to Node 1 DDR read latency 150 ns.
    - Node 1 Initiator to Local DDR read latency 100 ns.
    - Node 1 Initiator to Node 0 DDR read latency 140 ns.
    - Node 0 Initiator to Local DDR write latency 100 ns.
    - Node 0 Initiator to Node 1 DDR write latency 160 ns.
    - Node 1 Initiator to Local DDR write latency 110 ns.
    - Node 1 Initiator to Node 0 DDR write latency 150 ns.
* Bandwidth
    - Node 0 Initiator to Local DDR read Bandwidth 3200 MB/s
    - Node 0 Initiator to Node 1 DDR read Bandwidth 1600 MB/s
    - Node 0 Initiator to Local DDR write Bandwidth 3200 MB/s
    - Node 0 Initiator to Node 1 DDR write Bandwidth 1600 MB/s
    - Node 1 Initiator to Local DDR read Bandwidth 3000 MB/s
    - Node 1 Initiator to Node 0 DDR read Bandwidth 1600 MB/s
    - Node 1 Initiator to Local DDR write Bandwidth 3000 MB/s
    - Node 1 Initiator to Node 0 DDR write Bandwidth 1600 MB/s

This leads to the following 3 entries.

.. tabularcolumns:: |p{0.20\linewidth}|>{\centering\arraybackslash}p{0.15\linewidth}|p{0.50\linewidth}|
.. _hmat_sllbis_rl:
.. table:: Simple Topology HMAT System Locality Latency and Bandwidth
    Information Structure for memory read latency
    :widths: 70 55 200

    +--------------------+-----------+-----------------------------------+
    |    Field           |  Value    |   Notes                           |
    +====================+===========+===================================+
    | Type               | 1         | Identifies this as the "System    |
    |                    |           | Locality Latency and Bandwidth    |      
    |                    |           | Information Structure"            |      
    +--------------------+-----------+-----------------------------------+
    | Length             | N         |                                   |      
    +--------------------+-----------+-----------------------------------+
    | Flags              | 0         | For now we are only dealing with  |
    |                    |           | memory.                           |
    +--------------------+-----------+-----------------------------------+
    | Data Type          | 1         | This table is for DDR read        |
    |                    |           | latency. We cannot use access     |
    |                    |           | latency as the read and write     |
    |                    |           | latencies are not equal.          |   
    +--------------------+-----------+-----------------------------------+
    | Number of Initiator| 2         | We have processors, which are one |
    | Proximity Domains  |           | type of initiator, in Node 0 and  |
    |                    |           | Node 1.                           |
    +--------------------+-----------+-----------------------------------+
    | Number of Target   | 2         | We have DDR memory as targets     |
    | Proximity Domains  |           | in Node 0 and Node 1.             |
    +--------------------+-----------+-----------------------------------+
    | Entry Base Unit    |  1000     | 1000 corresponds to units of      |
    |                    |           | nano seconds. We could have used  |
    |                    |           | many different units here due to  |
    |                    |           | the relatively minor differences  |
    |                    |           | in latencies, but 1000 gives      |
    |                    |           | an easy understand scaling.       |
    +--------------------+-----------+-----------------------------------+
    | Initiator Proximity| 0         | 1st Initiator Proximity Domain    |          
    | Domain List Entry 0|           | for which we are providing        |
    |                    |           | latency information.              |
    +--------------------+-----------+-----------------------------------+
    | Initiator Proximity| 1         | 2nd Initiator Proximity Domain    |          
    | Domain List Entry 1|           | for which we are providing        |
    |                    |           | latency information.              |
    +--------------------+-----------+-----------------------------------+
    | Target Proximity   | 0         | 1st Target Proximity Domain       |          
    | Domain List Entry 0|           | for which we are providing        |
    |                    |           | latency information.              |
    +--------------------+-----------+-----------------------------------+
    | Target Proximity   | 1         | 2nd Target Proximity Domain       |          
    | Domain List Entry 1|           | for which we are providing        |
    |                    |           | latency information.              |
    +--------------------+-----------+-----------------------------------+
    | Entry[0][0]        | 90        | Node 0 to local DDR read          |
    |                    |           | latency, 90ns                     |          
    +--------------------+-----------+-----------------------------------+
    | Entry[0][1]        | 150       | Node 0 to Node 1 DDR read         |
    |                    |           | latency, 150ns                    |          
    +--------------------+-----------+-----------------------------------+
    | Entry[1][0]        | 140       | Node 1 to Node 0 DDR read         |
    |                    |           | latency, 140ns                    |          
    +--------------------+-----------+-----------------------------------+
    | Entry[1][1]        | 100       | Node 1 to local DDR read          |
    |                    |           | latency, 100ns                    |          
    +--------------------+-----------+-----------------------------------+

.. tabularcolumns:: |p{0.20\linewidth}|>{\centering\arraybackslash}p{0.15\linewidth}|p{0.50\linewidth}|
.. table:: Simple Topology HMAT System Locality Latency and Bandwidth
    Information Structure for memory write latency
    :widths: 70 55 200 

    +--------------------+-----------+-----------------------------------+
    |    Field           |  Value    |   Notes                           |
    +====================+===========+===================================+
    | Type               | 1         | Identifies this as the "System    |
    |                    |           | Locality Latency and Bandwidth    |      
    |                    |           | Information Structure"            |
    +--------------------+-----------+-----------------------------------+
    | Length             | N         |                                   |      
    +--------------------+-----------+-----------------------------------+
    | Flags              | 0         | For now we are only dealing with  |
    |                    |           | memory.                           |
    +--------------------+-----------+-----------------------------------+
    | Data Type          | 2         | This table is for DDR write       |
    |                    |           | latency. We cannot use access     |
    |                    |           | latency as the read and write     |
    |                    |           | latencies are not equal.          |   
    +--------------------+-----------+-----------------------------------+
    | Number of Initiator| 2         | We have processors, which are one |
    | Proximity Domains  |           | type of initiator, in Node 0 and  |
    |                    |           | Node 1.                           |
    +--------------------+-----------+-----------------------------------+
    | Number of Target   | 2         | We have DDR memory as targets     |
    | Proximity Domains  |           | in Node 0 and Node 1.             |
    +--------------------+-----------+-----------------------------------+
    | Entry Base Unit    |  1000     | 1000 corresponds to units of      |
    |                    |           | nano seconds. We could have used  |
    |                    |           | many different units here due to  |
    |                    |           | the relatively minor differences  |
    |                    |           | in latencies, but 1000 gives      |
    |                    |           | an easy understand scaling.       |
    +--------------------+-----------+-----------------------------------+
    | Initiator Proximity| 0         | 1st Initiator Proximity Domain    |          
    | Domain List Entry 0|           | for which we are providing        |
    |                    |           | latency information.              |
    +--------------------+-----------+-----------------------------------+
    | Initiator Proximity| 1         | 2nd Initiator Proximity Domain    |          
    | Domain List Entry 1|           | for which we are providing        |
    |                    |           | latency information.              |
    +--------------------+-----------+-----------------------------------+
    | Target Proximity   | 0         | 1st Target Proximity Domain       |          
    | Domain List Entry 0|           | for which we are providing        |
    |                    |           | latency information.              |
    +--------------------+-----------+-----------------------------------+
    | Target Proximity   | 1         | 2nd Target Proximity Domain       |          
    | Domain List Entry 1|           | for which we are providing        |
    |                    |           | latency information.              |
    +--------------------+-----------+-----------------------------------+
    | Entry[0][0]        | 100       | Node 0 to local DDR write         |
    |                    |           | latency, 100ns                    |          
    +--------------------+-----------+-----------------------------------+
    | Entry[0][1]        | 160       | Node 0 to Node 1 DDR write        |
    |                    |           | latency, 160ns                    |          
    +--------------------+-----------+-----------------------------------+
    | Entry[1][0]        | 150       | Node 1 to Node 0 DDR write        |
    |                    |           | latency, 150ns                    |          
    +--------------------+-----------+-----------------------------------+
    | Entry[1][1]        | 110       | Node 1 to local DDR write         |
    |                    |           | latency, 110ns                    |          
    +--------------------+-----------+-----------------------------------+

.. tabularcolumns:: |p{0.20\linewidth}|>{\centering\arraybackslash}p{0.15\linewidth}|p{0.50\linewidth}|
.. table:: Simple Topology HMAT System Locality Latency and Bandwidth
    Information Structure for memory access bandwidth
    :widths: 70 55 200

    +--------------------+-----------+----------------------------------+
    |    Field           |  Value    |   Notes                          |
    +====================+===========+==================================+
    | Type               | 1         | See :numref:`hmat_sllbis_rl`.    |
    +--------------------+-----------+----------------------------------+
    | Length             |           |                                  |      
    +--------------------+-----------+----------------------------------+
    | Flags              | 0         | For now we are only dealing with |
    |                    |           | memory.                          |
    +--------------------+-----------+----------------------------------+
    | Data Type          | 3         | This table is for memory access  |
    |                    |           | latency. The read and write      |
    |                    |           | bandwidths are symmetric         |
    |                    |           | allowing one entry to cover both.|   
    +--------------------+-----------+----------------------------------+
    | Number of Initiator| 2         | See :numref:`hmat_sllbis_rl`.    |
    | Proximity Domains  |           |                                  |
    +--------------------+-----------+----------------------------------+
    | Number of Target   | 2         | See :numref:`hmat_sllbis_rl`.    |
    | Proximity Domains  |           |                                  |
    +--------------------+-----------+----------------------------------+
    | Entry Base Unit    |  100      | 100 corresponds to units of      |
    |                    |           | 100 MiB/Sec.                     |
    +--------------------+-----------+----------------------------------+
    | Initiator Proximity| 0         | See :numref:`hmat_sllbis_rl`.    |          
    | Domain List Entry 0|           |                                  |
    +--------------------+-----------+----------------------------------+
    | Initiator Proximity| 1         | See :numref:`hmat_sllbis_rl`.    |          
    | Domain List Entry 1|           |                                  |
    +--------------------+-----------+----------------------------------+
    | Target Proximity   | 0         | See :numref:`hmat_sllbis_rl`.    |          
    | Domain List Entry 0|           |                                  |
    +--------------------+-----------+----------------------------------+
    | Target Proximity   | 1         | See :numref:`hmat_sllbis_rl`.    |          
    | Domain List Entry 1|           |                                  |
    +--------------------+-----------+----------------------------------+
    | Entry[0][0]        | 32        | Node 0 to local memory access    |
    |                    |           | bandwidth, 3200 MiB/Sec          |          
    +--------------------+-----------+----------------------------------+
    | Entry[0][1]        | 16        | Node 0 to Node 1 memory access   |
    |                    |           | bandwidth, 1600 MiB/Sec          |          
    +--------------------+-----------+----------------------------------+
    | Entry[1][0]        | 16        | Node 1 to Node 0 memory access   |
    |                    |           | bandwidth, 1600 MiB/Sec          |          
    +--------------------+-----------+----------------------------------+
    | Entry[1][1]        | 32        | Node 1 to local memory access    |
    |                    |           | bandwidth, 3200 MiB/Sec          |          
    +--------------------+-----------+----------------------------------+

We will leave the structures describing Memory-Side Caches until :numref:`secmemorysidecache`.

.. _secpxm:

Proximity Domain Specification in DSDT / SSDT
=============================================

The ACPI specification provides no means of specifying additional Proximity
Domains outside of affinity entries in SRAT.  However, it does provide a means
of assigning additional devices to a Proximity Domain which has been defined
by means of an SRAT affinity entry for other devices.

This is done using the Proximity (_PXM) object for a device in the
Differentiated System Descriptor Table (DSDT) or Secondary System
Descriptor Tables (SSDT).

Prior to ACPI 6.3 this was the only way of providing proximity information
about types of device that are not CPUs, Memory or ITSes.

It is not currently possible to provide NUMA information for a new hot-plugged
domain that had no previous elements in SRAT.  This means that *potential*
hardware must be presented at boot, rather than simply what is present at
that time.  It is possible to modify the NUMA characteristics of that hardware
to reflect the reality of what was plugged in.  This is covered in more detail
in :numref:`sechotplug`.  
