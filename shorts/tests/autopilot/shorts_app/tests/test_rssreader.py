# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Copyright (C) 2013, 2014 Canonical Ltd.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation; version 3.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

"""shorts app autopilot tests."""

from autopilot.matchers import Eventually
from testtools.matchers import Equals, NotEquals

from shorts_app.tests import ShortsAppTestCase
import uuid
import logging

logger = logging.getLogger(__name__)


_EXTERNAL_FEED_URL = 'http://www.canonical.com/rss.xml'
_EXTERNAL_FEED_TITLE = 'Ubuntu Insights'


class BaseShortsAppTestCase(ShortsAppTestCase):

    def setUp(self):
        super(BaseShortsAppTestCase, self).setUp()
        unique_id = str(uuid.uuid1())
        self.test_feed_url = _EXTERNAL_FEED_URL
        self.test_feed_title = _EXTERNAL_FEED_TITLE
        self.test_topic = 'Test topic {}'.format(unique_id)
        self.test_change_topic = 'Ubuntu'

        # wait for any updates to finish before beginning tests
        self._wait_for_refresh()

    def _wait_for_refresh(self):
        try:
            self.assertThat(
                self.app.main_view.get_network_activity,
                Eventually(NotEquals(None), timeout=5))
            self.assertThat(
                self.app.main_view.get_network_activity,
                Eventually(Equals(None), timeout=60))
        except:
            self.assertThat(
                self.app.main_view.get_network_activity,
                Eventually(Equals(None), timeout=60))

    def add_feed_to_new_topic(self, feed_url, feed_title, topic):
        add_feeds_page = self.app.main_view.go_to_add_feeds()
        # XXX here we are using an external server because we are currently
        # using the Google Feed API, which doesn't let us access local
        # resources. --elopio - 2014-02-26
        add_feeds_page.search_feed(feed_url)
        add_feeds_page.select_results(feed_title)
        choose_topics_page = add_feeds_page.click_next()
        choose_topics_page.add_topic(topic)
        # TODO move this wait to the main view custom proxy object.
        # --elopio - 2014-02-26
        self._wait_for_refresh()


class TestMainWindow(BaseShortsAppTestCase):

    def test_add_feed_to_new_topic(self):
        """Test that adding a feed to a new topic must show it in a new tab."""
        self.add_feed_to_new_topic(
            self.test_feed_url, self.test_feed_title, self.test_topic)

        selected_tab_title = self.app.main_view.get_selected_tab_title()
        self.assertEqual(self.test_topic, selected_tab_title)

    def test_switch_to_list_view_mode(self):
        """ test switching to list view  mode"""
        shorts_tab = self.app.main_view.get_shorts_tab()
        self._ensure_grid_view_mode(shorts_tab)
        self.app.main_view.change_view_mode("isNotListMode")
        self.assertThat(shorts_tab.isListMode, Eventually(Equals(True)))

    def test_switch_to_grid_view_mode(self):
        """ test switching to grid view  mode"""
        shorts_tab = self.app.main_view.get_shorts_tab()
        self._ensure_list_view_mode(shorts_tab)
        self.app.main_view.change_view_mode("isListMode")
        self.assertThat(shorts_tab.isListMode, Eventually(Equals(False)))

    def _ensure_grid_view_mode(self, current_tab):
        if current_tab.isListMode:
            self.app.main_view.change_view_mode("isListMode")

    def _ensure_list_view_mode(self, current_tab):
        if not current_tab.isListMode:
            self.app.main_view.change_view_mode("isNotListMode")

    def test_open_listmode_feed_item(self):
        """"test to ensure list mode feed items can be opened"""

        self.add_feed_to_new_topic(
            self.test_feed_url, self.test_feed_title, self.test_topic)
        new_topic_tab = self.app.main_view.get_topic_tab(self.test_topic)
        self._ensure_list_view_mode(new_topic_tab)

        self.app.main_view.open_feed_item(
            self.test_topic, self.test_feed_title)
        self.assertEqual(
            self.app.main_view.get_feed_in_feedlist_title(
                self.test_topic, self.test_feed_title),
            self.app.main_view.get_articleviewitem_title())

    def test_edit_topic(self):
        """test edit topic"""

        self.add_feed_to_new_topic(
            self.test_feed_url, self.test_feed_title, self.test_topic)

        self.app.main_view.click_edit_topics_in_header()
        topicManagementPage = self.app.main_view.get_feed_management_page()
        topicManagementPage.expand_topic(self.test_topic)

        # change feed's topic
        topicManagementPage.goto_feed_in_topic(
            self.test_topic, self.test_feed_title)
        editFeedpage = self.app.main_view.get_edit_feed_page()
        editFeedpage.change_feeds_topic(self.test_change_topic)
        self.app.main_view.click_header_done_button()

        # verify topic has changed
        newTopic = topicManagementPage.wait_select_single(
            "TopicComponent", topicName=self.test_change_topic)
        self.assertThat(newTopic.wait_select_single(
            "FeedComponent", text=self.test_feed_title).text,
            Eventually(Equals(self.test_feed_title)))


class ShortsTestCaseWithTopicAndFeed(BaseShortsAppTestCase):

    def setUp(self):
        super(ShortsTestCaseWithTopicAndFeed, self).setUp()
        self.add_feed_to_new_topic(
            self.test_feed_url, self.test_feed_title, self.test_topic)

    def test_remove_feed(self):
        """Test the removal of a feed from the Edit Feeds page."""
        self.app.main_view.click_edit_topics_in_header()
        edit_feeds_page = self.app.main_view.get_edit_feeds_page()
        edit_feeds_page.expand_topic(self.test_topic)
        feeds = edit_feeds_page.get_feeds_in_topic(self.test_topic)
        self.assertIn(self.test_feed_title, feeds)
        edit_feeds_page.delete_feed(self.test_topic, self.test_feed_title)
        feeds = edit_feeds_page.get_feeds_in_topic(self.test_topic)
        self.assertNotIn(self.test_feed_title, feeds)

    def test_remove_topic(self):
        """Test the removal of a topic from the Edit Topics page."""
        self.app.main_view.click_edit_topics_in_header()
        edit_feeds_page = self.app.main_view.get_edit_feeds_page()
        edit_feeds_page.delete_topic(self.test_topic)
        topics = edit_feeds_page.get_topics()
        self.assertNotIn(self.test_topic, topics)
