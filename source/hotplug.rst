.. _sechotplug:

=============================================
Hotplug and dynamically updating the topology
=============================================

In this case we are only interested in hotplug of elements of the
system which would, had they been present at boot, have appeared
as entries in SRAT.

The ACPI specification does not allow *new* proximity nodes to be
created when such hotplug events occur, but it does allow for
existing NUMA characteristics to be updated.  This allows
proximity nodes to be set aside for *potential* hotplug entities
and their characteristics to be modified once the actual system
elements being hotplugged are known.

The Linux kernel, at time of writing, does not make use of these
ACPI objects, and it is not known if other operating systems do
so.  They are included here to make the reader aware of the features
available in the ACPI specification, even if operating systems
do not yet make use of them.

* **_SLI** provides updates of the information found at boot time
  via the SLIT table. Only information about a new node is provided.

* **_HMA** provides an updated HMAT in entirety, overriding the
  existing, boot time HMAT table.