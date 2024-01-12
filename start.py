#!/usr/bin/env python
"""
Installs FiftyOne.

| Copyright 2017-2023, Voxel51, Inc.
| `voxel51.com <https://voxel51.com/>`_
|
"""
import fiftyone as fo
import fiftyone.zoo as foz
print(foz.list_zoo_datasets())

if __name__ == "__main__":
    fo.app_config.theme="light"
    dataset = foz.load_zoo_dataset("quickstart")
    # Give the dataset a new name, and make it persistent so that you can
    # work with it in future sessions
    session = fo.launch_app(dataset)
    session.wait(-1)