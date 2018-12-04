.. |nbsp| unicode:: 0xA0 
   :trim:

.. _gasect:

=========================
Generic Initiators - Why?
=========================

In the modern world of heterogenous compute, some of the traditional underlying
assumptions of what devices will be accessing memory and how they
will be doing it are no longer true.

We will first address a very simple example, but the increasing use
of computing accelerators and memory over coherent, pluggable fabrics
means that a generic solution to this description problem is needed.

Original Assumptions
====================

1. Most accesses to memory are done by devices that are closely coupled
   with CPUs on the host, hence it is sufficient to describe the CPU
   access properties to memory and assume it is similar for other
   memory users.

2. The properties of accesses from peripheral devices will be closely
   correlated with the those of the host to which they are most
   closely coupled.

3. An Operating system only needs to make relative decisions so it doesn't
   matter if there are additional constraints on bandwidth or additional
   latency on the path to peripheral devices. 

.. _figsimplenodesplusga:
.. figure:: simplenodesplusga.*
    :figclass: align-center

    A simple configuration where these legacy assumptions do not hold.

Taking the hypothetical example in :numref:`figsimplenodesplusga` where we have a
separate IO device from the devices containing the processors and DDR controllers,
it becomes clear that these assumptions do not always hold.

1. The IO device has an RDMA adapter.  Which existing node do we assign this
   device to as it is equal distance from Node 0 DDR and Node 1 DDR?

2. The IO device is on a similar ring bus connection to that between the NUMA nodes.
   As shown in :numref:`figsimplenodesplus_non_ga`, putting the IO device in either
   of the existing nodes would imply one set of DDR was much nearer than the other.

.. _figsimplenodesplus_non_ga:
.. figure:: simplenodesplus_non_ga.*
    :figclass: align-center

    The ACPI view of our balanced case, as show in :numref:`figsimplenodesplusga`, prior to
    the introduction of Generic Initiators.  Note the relative distance from our
    RDMA adaptor is falsely represented as different for Memory |nbsp| 0 and Memory |nbsp| 1.

3. An RDMA adapter, in common with many modern IO devices has many separate
   contexts each with their own resources.  Traditionally we would place these
   these in the *nearest* memory that can be found.  If however, we have two
   equal distance memory resources and the bandwidth to each is independent,
   it may be beneficial for the Operating System to decide to put the data for
   some of those contexts in Node 0 and some in Node 1 - a form of NUMA balancing.

This simple example shows why we need the new (in ACPI 6.3) concept of a
Proximity Domain with a Generic Initiator.  Note that Generic Initiators can
share a Proximity Domain with Memory and/or CPUs but they can also, as in
:numref:`figsimplenodesplusga` have a domain all of their own.  Under previous
versions of the ACPI specification, the GI within an existing Proximity Domain
could be described using _PXM, the case where they are on their own could not
be described at all.

Generic Initiator Additions
===========================

The ACPI specification was not greatly modified to allow for Generic Initiators,
but as this is new in ACPI 6.3, we will highlight a few necessary changes that
were made.

SRAT Generic Initiator Affinity Structure
-----------------------------------------

Alongside the existing CPU, Memory and ITS Affinity Structures in SRAT a new
simple one was added to allow for Generic Initiator Proximity Domains to
be described.

One complexity in here is that we need a means of identifying which device
is our Generic Initiator.  Currently two means are defined for doing this,
either via a PCI Device Handle, or an ACPI Device Handle.  Here we shall
only consider the PCI Device Handle option, but the ACPI Device Handle
follows a similar approach.

Expanding our example
.....................

Let us assume that the RDMA adapter is on a PCIe bus (the root complex may
be in the IO device as well so we have a standard PCIe bus attached to
a point on a ring interconnect).  This amended example is shown in
:numref:`figsimplenodesplusgapci`.

.. _figsimplenodesplusgapci:
.. figure:: simplenodesplusgapci.*
    :figclass: align-center

    An expanded GA example including a PCIe bus with the root port also being found
    within our Generic Initiator domain.

Rather than repeating the whole of SRAT above, this may be simply added
to the end

.. tabularcolumns:: |p{0.20\linewidth}|>{\centering\arraybackslash}p{0.15\linewidth}|p{0.50\linewidth}|
.. table:: Generic Initiator Affinity Structure
    :widths: 70 55 200 

    +--------------------+-----------+----------------------------------+
    |    Field           |  Value    |   Notes                          |
    +====================+===========+==================================+
    | Type               | 5         | Generic Initiator Affinity       |
    |                    |           | Structure                        | 
    +--------------------+-----------+----------------------------------+
    | Length             | 32        |                                  | 
    +--------------------+-----------+----------------------------------+
    | Device Handle Type | 1         | Providing a PCI Device Handle    | 
    +--------------------+-----------+----------------------------------+
    | Proximity Domain   | 2         | Our new Generic Initiator        |
    |                    |           | Proximity Domain - in this case  |
    |                    |           | we have no other SRAT Affinity   |
    |                    |           | Structures referring to domain 2.|
    +--------------------+-----------+----------------------------------+
    | PCI Segment        | 0         |                                  | 
    +--------------------+-----------+----------------------------------+
    | PCI BDF            | 0x10      | Bus 1, device 0, function 0      | 
    +--------------------+-----------+----------------------------------+
    | Flags              | 1         | Enabled                          | 
    +--------------------+-----------+----------------------------------+


Legacy OS handling of these new domains
---------------------------------------

Operating Systems that have ACPI support predating ACPI 6.3 are naturally
unaware of Generic Initiator Structures.  Linux at least is known to
ignore Affinity Structures in SRAT if their type is not one that is already
handled. Thus, there is no direct side effect of ACPI being used to tell
a legacy operating system about them.

However, as we mentioned in :numref:`secpxm`, there is another means
of assigning devices to a Proximity Domain.  An entry describing the
device in the Differentiated System Descriptor Table (DSDT) or
Secondary System Descriptor Table (SSDT) may use the Proximity (_PXM) object
to specify which Proximity Domain a device lies within.

However, what does a legacy operating system do if a device is thus
assigned to a proximity domain which it does not know exists?  In the case
of some versions of Linux the answer is unfortunately that it crashes.
Even assuming this less than ideal response is fixed, there is no means for
the OS to know the 'best alternative' proximity domain to put the device in
given the OS is not ready to handle Generic Initiator Domains.

This problem is worked around by use of a new _OSC bit defined in ACPI 6.3
which allows the proximity domain provided by _PXM to be changed dependent
on whether the OS communicates that it supports Generic Initiators or not.
This *fallback domain* should be chosen to describe a topology that allows
the Operating System to make the best decision it can under the constraints
of pre Generic Initiator ACPI.  In our example :numref:`figsimplenodesplusga`
we simply pick one of the nodes on the basis they are equal in all ways.
