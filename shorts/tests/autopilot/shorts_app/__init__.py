# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""RSS reader app tests and emulators - top level package."""

import logging
from time import sleep

from autopilot import logging as autopilot_logging
from testtools.matchers import NotEquals

from ubuntuuitoolkit import (
    emulators as toolkit_emulators
)


logger = logging.getLogger(__name__)


class ShortsApp(object):

    """Autopilot helper object for shorts."""

    def __init__(self, app_proxy, test_type):
        self.app = app_proxy
        self.test_type = test_type
        self.main_view = self.app.select_single(MainView)

    @property
    def pointing_device(self):
        return self.app.pointing_device


class ShortsAppException(Exception):

    """Exception raised when something is wrong with the Shorts app."""


class MainView(toolkit_emulators.MainView):

    retry_delay = 0.2

    @autopilot_logging.log_action(logger.info)
    def go_to_add_feeds(self):
        self._click_add_reads()
        return self.wait_select_single(AppendFeedPage)

    @autopilot_logging.log_action(logger.info)
    def get_edit_feeds_page(self):
        """Go to the edit feeds page."""
        return self.wait_select_single(
            TopicManagement, objectName='topicmanagement')

    def _click_add_reads(self):
        # does not work using workaround
        # header = self.get_header()
        # header.click_action_button('Add feeds')

        # -------------------------------------------------------------------
        # this will have to bee removed after fixing above header issue
        actionsButton = self.wait_select_single(
            "PageHeadButton", objectName='actions_overflow_button')
        self.pointing_device.click_object(actionsButton)
        popover = self.wait_select_single(
            "StyledItem", objectName="popover_foreground")
        addReadsAction = popover.wait_select_single(
            "AbstractButton", text="Add feeds")
        self.pointing_device.click_object(addReadsAction)
        # -----------------------------------------------------------------

    def get_selected_tab_title(self):
        tabs = self.get_tabs()
        selected_tab_index = tabs.selectedTabIndex
        # TODO there are other tabs that are not of TopicTab type.
        # --elopio - 2014-02-26
        tab = tabs.select_single('TopicTab', index=selected_tab_index)
        return tab.title

    def select_many_retry(self, object_type, **kwargs):
        """Returns the item that is searched for with app.select_many
        In case of no item was not found (not created yet) a second attempt is
        taken 1 second later"""
        items = self.select_many(object_type, **kwargs)
        tries = 10
        while len(items) < 1 and tries > 0:
            sleep(self.retry_delay)
            items = self.select_many(object_type, **kwargs)
            tries = tries - 1
        return items

    def get_network_activity(self):
        try:
            activity = self.select_single("ActivityIndicator", running="True")
        except:
            return
        return activity

    def strip_html_tags(self, text):
        finished = 0
        while not finished:
            finished = 1
            start = text.find("<")
            if start >= 0:
                stop = text[start:].find(">")
                if stop >= 0:
                    text = text[:start] + text[start + stop + 1:]
                    finished = 0
        return text

    # choose topics page objects
    def get_choose_topics_items(self):
        return self.select_many("Standard", objectName="topicItem")

    def get_new_topic_input_box(self):
        return self.select_single("TextField", objectName="newTopic")

    # append feed page objects
    def get_append_feed_input_box(self):
        return self.select_single("TextField", objectName="tfFeedUrl")

    def get_append_page_feed(self):
        # grab just the first checkbox
        return self.select_many_retry("CheckBox", objectName="feedCheckbox")[0]

    def get_next_button(self):
        return self.select_single("Button", objectName="nextButton")

    # feed list page objects
    def get_add_a_topic(self):
        return self.select_single("QQuickItem", objectName="addTopic")

    # edit feed page objects
    def get_delete_button(self):
        return self.select_single("Button", objectName="deleteButton")

    # Page Calls
    def get_feedlist_page(self):
        return self.wait_select_single("FeedListPage",
                                       objectName="feedlistpage")

    def get_articlelist_page(self):
        return self.select_single("ArticleListPage",
                                  objectName="articlelistpage")

    def get_feed_management_page(self):
        return self.wait_select_single("TopicManagement",
                                       objectName="topicmanagement")

    def get_edit_feed_page(self):
        return self.select_single("EditFeedPage",
                                  objectName="editfeedpage")

    def get_manage_topics_page(self):
        return self.select_single("ManageTopicsPage")

    def get_rss_feed_page(self):
        return self.wait_select_single("ArticleViewPage",
                                       objectName="rssfeedpage")

    def get_shorts_tab(self):
        return self.wait_select_single("ShortsTab", objectName="Tab0")

    def get_topics(self):
        return self.select_single("QQuickListView", objectName="topiclist")

    def get_feeds(self):
        return self.select_many("Standard", objectName="FeedListItem")

    def get_header(self):
        return self.select_many("Header")

    def get_all_feeds(self):
        return self.select_single("Subtitled", text="All articles")

    def get_refresh_button(self):
        return self.select_single("AbstractButton", objectName="refreshbutton")

    def get_list_view_button(self):
        return self.select_single("AbstractButton",
                                  objectName="listviewbutton")

    def get_add_feed_button(self):
        return self.select_single("AbstractButton", objectName="addfeedbutton")

    def get_edit_topic_button(self):
        return self.select_single("AbstractButton",
                                  objectName="edittopicbutton")

    def get_refresh_feed_dialog(self):
        return self.select_single("Dialog", objectName="refreshWaitDialog")

    def get_refresh_dialog_cancel_button(self):
        return self.select_single("Button", objectName="refreshCancel")

    def get_toolbar_back_button(self):
        return self.select_single("ActionItem", text="Back")

    def get_editfeed_done_button(self):
        return self.wait_select_single("Button", objectName="doneButton")

    def get_topic_tab(self, topic):
        return self.wait_select_single("TopicTab", title=topic)

    @autopilot_logging.log_action(logger.info)
    def open_feed_item(self, test_topic, test_feed_title):
        feed_in_feeedlist = self._get_feed_in_feedlist(
            test_topic, test_feed_title)
        self.pointing_device.click_object(feed_in_feeedlist)

    def _get_feed_in_feedlist(self, topic, feed):
        itemList = self._get_feedlist(topic)
        for item in itemList:
            label = item.select_single("Label", objectName="labelFeedname")
            if label.text == feed:
                return item

    def _get_feedlist(self, topic):
        items = self.select_many(objectName="feedlistitems")
        return items

    def get_feed_in_feedlist_title(self, test_topic, test_feed_title):
        feed_in_feeedlist = self._get_feed_in_feedlist(
            test_topic, test_feed_title)
        return feed_in_feeedlist.select_single(
            "Label", objectName="label_title").text

    def get_articleviewitem_title(self):
        flickable = self._get_articleview_flickables()
        return flickable.select_single(
            "Label", objectName="articleviewitem_title").text

    def _get_articleview_flickables(self):
        flickables_list = self.select_many(
            "QQuickFlickable", objectName="articleview_flickable")
        for flickable in flickables_list:
            if flickable.focus:
                return flickable

    @autopilot_logging.log_action(logger.info)
    def change_view_mode(self, mode):
        """Change view mode.

        :parameter mode: if you are in list mode it equals "isListMode"
                         if you are not in list mode it equals "isNotListMode"

        """

        # does not work using workaround
        """
        header = self.get_header()
        if mode == "isListMode":
            header.click_action_button("Grid View")
        else:
            header.click_action_button("List view")
        """
        # -------------------------------------------------------------------
        # this will have to bee removed after fixing above header issue
        actionsButton = self.wait_select_single(
            "PageHeadButton", objectName='actions_overflow_button')
        self.pointing_device.click_object(actionsButton)
        popover = self.wait_select_single(
            "StyledItem", objectName="popover_foreground")
        if mode == "isListMode":
            addReadsAction = popover.wait_select_single(
                "AbstractButton", text="Grid View")
        else:
            addReadsAction = popover.wait_select_single(
                "AbstractButton", text="List view")

        self.pointing_device.click_object(addReadsAction)
        # -----------------------------------------------------------------

    @autopilot_logging.log_action(logger.info)
    def click_edit_topics_in_header(self):
        """
        does not work using workaround
        header = self.get_header()
        header.click_action_button('editTopicsAction')
        """
        # -------------------------------------------------------------------
        # this will have to bee removed after fixing above header issue
        # reported bug #1412967 -- 20/01/2015
        actionsButton = self.wait_select_single(
            "PageHeadButton", objectName='actions_overflow_button')
        self.pointing_device.click_object(actionsButton)
        popover = self.wait_select_single(
            "StyledItem", objectName="popover_foreground")
        addReadsAction = popover.wait_select_single(
            "AbstractButton", text="Edit topics")

        self.pointing_device.click_object(addReadsAction)
        # -----------------------------------------------------------------

    @autopilot_logging.log_action(logger.info)
    def click_header_done_button(self):
        """
        does not work using workaround

        header = self.get_header()
        header.click_action_button("doneButton")

        """
        # -------------------------------------------------------------------
        # this will have to bee removed after fixing above header issue
        # reported bug #1412967 -- 20/01/2015
        actionsButton = self.wait_select_single(
            "PageHeadButton", objectName='doneButton_header_button')
        self.pointing_device.click_object(actionsButton)


class Page(toolkit_emulators.MainView):

    """Autopilot helper for the Page objects."""

    def __init__(self, *args):
        super(Page, self).__init__(*args)
        # XXX we need a better way to keep reference to the main view.
        # --elopio - 2014-02-26
        self.main_view = self.get_root_instance().select_single(MainView)


class AppendFeedPage(Page):

    """Autopilot helper for the Append Feed page."""

    @autopilot_logging.log_action(logger.info)
    def search_feed(self, keyword_or_url):
        search_text_field = self.select_single(
            toolkit_emulators.TextField, objectName='tfFeedUrl')
        # Write and press enter.
        search_text_field.write(keyword_or_url + '\n')
        self._wait_for_results_to_appear()

    @autopilot_logging.log_action(logger.info)
    def click_next_button(self):
        next_button = self.wait_select_single(
            'Button', objectName='nextButton')
        self.pointing_device.click_object(next_button)

    def _wait_for_results_to_appear(self):
        results_list = self._get_results_list()
        results_list.count.wait_for(NotEquals(0))

    def _get_results_list(self):
        return self.select_single(
            toolkit_emulators.QQuickListView, objectName='feedpagelistview')

    @autopilot_logging.log_action(logger.info)
    def select_results(self, *results):
        """Select feed items from the list of results.

        :param results: The titles of the items to select from the list.

        """
        for result in results:
            self._check_result(result)

    def click_next(self):
        self.click_next_button()
        return self.main_view.select_single(
            ChooseTopicPage, objectName='choosetopicpage')

    def _check_result(self, result):
        results_list = self._get_results_list()
        results_list.click_element('feedCheckbox-{}'.format(result))


class ChooseTopicPage(Page):

    """Autopilot helper for the Choose Topic Page page."""

    @autopilot_logging.log_action(logger.info)
    def add_topic(self, topic):
        new_topic_text_field = self.select_single(
            toolkit_emulators.TextField, objectName='newTopic')
        # Write and press enter.
        new_topic_text_field.write(topic + '\n')


class TopicManagement(Page):

    """Autopilot helper for the Edit topics page."""

    @autopilot_logging.log_action(logger.info)
    def expand_topic(self, topic_name):
        """Expand a topic if it's not already expanded.

        :param topic_name: The name of the topic.

        """
        topic_component = self._get_topic_component(topic_name)
        if topic_component.isExpanded:
            logger.debug('The topic is already expanded.')
        else:
            self.pointing_device.click_object(topic_component)
            topic_component.isExpanded.wait_for(True)

    @autopilot_logging.log_action(logger.info)
    def collapse_topic(self, topic_name):
        """Collapse a topic if it's not already collapsed.

        :param topic_name: The name of the topic.

        """
        topic_component = self._get_topic_component(topic_name)
        if not topic_component.isExpanded:
            logger.debug('The topic is already collapsed.')
        else:
            label = topic_component.select_single('Label', text=topic_name)
            self.pointing_device.click_object(label)
            topic_component.isExpanded.wait_for(False)

    def _get_topic_component(self, topic_name):
        return self.wait_select_single(TopicComponent, topicName=topic_name)

    @autopilot_logging.log_action(logger.info)
    def delete_topic(self, topic_name):
        """Delete a topic.

        :param topic_name: The name of the topic.

        """
        self.collapse_topic(topic_name)
        topic_component = self._get_topic_component(topic_name)
        topic_element = topic_component.select_single(
            toolkit_emulators.Base, objectName="headerTopic")
        topic_element.swipe_to_delete()
        topic_element.confirm_removal()

    @autopilot_logging.log_action(logger.info)
    def delete_feed(self, topic_name, feed_title):
        """Delete a feed item.

        :param topic_name: The name of the topic.
        :param feed_title: The title of the feed to delete.

        """
        topic_component = self._get_topic_component(topic_name)
        count_before_delete = self._get_number_of_feeds_in_topic(topic_name)
        feed_component = topic_component.select_single(
            FeedComponent, text=feed_title)
        feed_component.swipe_to_delete()
        self._get_feeds_list(topic_name).count.wait_for(
            count_before_delete - 1)

    def _get_number_of_feeds_in_topic(self, topic_name):
        feeds_list = self._get_feeds_list(topic_name)
        return feeds_list.count

    def _get_feeds_list(self, topic_name):
        topic_component = self._get_topic_component(topic_name)
        return topic_component.select_single('QQuickListView')

    def get_feeds_in_topic(self, topic_name):
        """Return the list of feeds in a topic.

        The list contains the titles of the feeds.

        """
        topic_component = self._get_topic_component(topic_name)
        if topic_component.isExpanded:
            feed_components = topic_component.select_many(FeedComponent)
            return [feed_component.text for feed_component in feed_components]
        else:
            raise ShortsAppException('The topic is not expanded.')

    @autopilot_logging.log_action(logger.info)
    def goto_feed_in_topic(self, test_topic, test_feed_title):
        """Return the feed passed as argument.         """
        topic_component = self.wait_select_single(
            TopicComponent, topicName=test_topic)
        self.pointing_device.click_object(topic_component.select_single(
            FeedComponent, text=test_feed_title))

    def get_topics(self):
        """Return the list of the topics available.

        The list contains the titles of the topics.

        """
        topic_components = self.select_many(TopicComponent)
        topics = []
        for component in topic_components:
            label = component.select_single(
                "Label", objectName="labelTopicName")
            topics.append(label)
        return topics


class EditFeedPage(Page):

    """Autopilot helper for the Edit Feed page."""
    @autopilot_logging.log_action(logger.info)
    def change_feeds_topic(self, name):
        """ change feed's topic """
        topicValueselector = self._get_editfeed_topic_valueselector()
        self.pointing_device.click_object(topicValueselector)
        topicValueselector.expanded.wait_for(True)
        newTopic = self._get_editfeed_valueselector_value(name)
        newTopic.visible.wait_for(True)
        self.pointing_device.click_object(newTopic)

    def _get_editfeed_topic_valueselector(self):
        return self.wait_select_single(
            "ValueSelector", objectName="valueselector")

    def _get_editfeed_valueselector_value(self, name):
        return self.wait_select_single("LabelVisual", text=name)


class FeedComponent(toolkit_emulators.Empty):

    """Autopilot helper for the Feed Component list item."""
    @autopilot_logging.log_action(logger.info)
    def swipe_to_delete(self):
        """Swipe the item in a specific direction."""
        # Overriden because the swipe to delete is implemented in the
        # FeedComponent. See bug http://pad.lv/1311800
        self.removable = True
        self.confirmRemoval = False
        super(FeedComponent, self).swipe_to_delete()


class TopicComponent(toolkit_emulators.Empty):

    """Autpilot helper for the Topic Component list item."""
