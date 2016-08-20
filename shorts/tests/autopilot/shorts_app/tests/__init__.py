# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Copyright (C) 2013 Canonical Ltd
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Authored by: Renato Araujo Oliveira Filho <renato@canonical.com>


"""shorts-app autopilot tests."""

import os.path
import shutil
import logging

from autopilot.platform import model
from autopilot import logging as autopilot_logging
from autopilot.testcase import AutopilotTestCase

import shorts_app

import ubuntuuitoolkit
from ubuntuuitoolkit import base
import fixtures

logger = logging.getLogger(__name__)


class BaseTestCaseWithPatchedHome(AutopilotTestCase):

    """A common test case class that provides several useful methods for
    rssreader-app tests.

    """

    local_location = os.path.dirname(os.path.dirname(os.getcwd()))
    local_location_qml = os.path.join(local_location, 'shorts-app.qml')
    installed_location_qml = "/usr/share/shorts-app/shorts-app.qml"

    def get_launcher_and_type(self):
        if os.path.exists(self.local_location_qml):
            launcher = self.launch_test_local
            test_type = 'local'
        elif os.path.exists(self.installed_location_qml):
            launcher = self.launch_test_installed
            test_type = 'deb'
        else:
            launcher = self.launch_test_click
            test_type = 'click'
        return launcher, test_type

    def setUp(self):
        super(BaseTestCaseWithPatchedHome, self).setUp()
        self.launcher, self.test_type = self.get_launcher_and_type()
        self.home_dir = self.patch_home()

        # turn off the OSK so it doesn't block screen elements
        if model() != 'Desktop':
            os.system("stop maliit-server")
            self.addCleanup(os.system, "start maliit-server")

    @autopilot_logging.log_action(logger.info)
    def launch_test_local(self):
        return self.launch_test_application(
            base.get_qmlscene_launch_command(),
            self.local_location_qml,
            app_type='qt',
            emulator_base=ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase)

    @autopilot_logging.log_action(logger.info)
    def launch_test_installed(self):
        return self.launch_test_application(
            base.get_qmlscene_launch_command(),
            self.installed_location_qml,
            app_type='qt',
            emulator_base=ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase)

    @autopilot_logging.log_action(logger.info)
    def launch_test_click(self):
        return self.launch_click_package(
            "com.ubuntu.shorts",
            emulator_base=ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase)

    def _copy_xauthority_file(self, directory):
        """ Copy .Xauthority file to directory, if it exists in /home
        """
        # If running under xvfb, as jenkins does,
        # xsession will fail to start without xauthority file
        # Thus if the Xauthority file is in the home directory
        # make sure we copy it to our temp home directory

        xauth = os.path.expanduser(os.path.join(os.environ.get('HOME'),
                                   '.Xauthority'))
        if os.path.isfile(xauth):
            logger.debug("Copying .Xauthority to %s" % directory)
            shutil.copyfile(
                os.path.expanduser(os.path.join(os.environ.get('HOME'),
                                   '.Xauthority')),
                os.path.join(directory, '.Xauthority'))

    def patch_home(self):
        """ mock /home for testing purposes to preserve user data
        """

        # if running on non-phablet device,
        # run in temp folder to avoid mucking up home
        # bug 1316746
        # bug 1376423
        if self.test_type is 'click':
            # just use home for now on devices
            temp_dir = os.environ.get('HOME')
        else:
            temp_dir_fixture = fixtures.TempDir()
            self.useFixture(temp_dir_fixture)
            temp_dir = temp_dir_fixture.path

            # before we set fixture, copy xauthority if needed
            self._copy_xauthority_file(temp_dir)
            self.useFixture(fixtures.EnvironmentVariable('HOME',
                                                         newvalue=temp_dir))

            logger.debug("Patched home to fake home directory %s" % temp_dir)
        return temp_dir


class ShortsAppTestCase(BaseTestCaseWithPatchedHome):

    """Base test case that launches shorts-app"""

    def setUp(self):
        super(ShortsAppTestCase, self).setUp()
        self.app = shorts_app.ShortsApp(self.launcher(), self.test_type)
