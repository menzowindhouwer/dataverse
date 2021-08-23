GDCC fork of IQSS/dataverse
===========================

--- DO NOT FETCH UPSTREAM CODE IN THIS BRANCH ---

This forks maintains an up-to-date branch of `IQSS:master <https://github.com/gdcc/dataverse/tree/master>`_
and `IQSS:develop <https://github.com/gdcc/dataverse/tree/develop>`_ by using `wei/pull <https://github.com/wei/pull>`_

Feature Branches
----------------

1. Containers: branch `gdcc:develop+ct <https://github.com/gdcc/dataverse/tree/develop+ct>`_ contains changes to create
   container images for Dataverse and Solr with Maven. It can be used for lot's of purposes regarding containers, using
   Docker, Podman, etc.

   It is automatically updated with the latest upstream ``develop`` branch. You can also see the differences and
   `container related additions here <https://github.com/IQSS/dataverse/compare/develop...gdcc:develop+ct>`_
   
2. Production containers: branch `gdcc:master+ct <https://github.com/gdcc/dataverse/tree/master+ct>`_ is based on
   upstream stable branch. It will incorporate container related changes from `develop+ct`.
   This is done manually (no way to avoid this).
   
   Tagged container image releases will be built from this branch.
   
   To create/update the branch do the cherry picking:
   
   1. Switch to clean ``master+ct`` branch, based on latest upstream ``master`` (or from another tag release)
   2. Use ``git log master+ct...develop+ct ^develop --no-merges --oneline --cherry-mark --reverse``. Revisit all changes to suffice
   3. Do the picking: ``git log master+ct...develop+ct ^develop --no-merges --oneline --cherry-pick --reverse --format=%h | xargs git cherry-pick``
   4. Force push (as we rewrote history)
   
   (Maybe we can find a workaround for the forced pushes?)

To use the same for other branches, features etc, create a PR against ``.github/pull.yml`` and add some docs here.
