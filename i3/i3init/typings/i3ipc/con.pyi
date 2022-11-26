"""
This type stub file was generated by pyright.
"""

from typing import List, Optional

from . import replies

class Con:
    """A container of a window and child containers gotten from :func:`i3ipc.Connection.get_tree()` or events.

    .. seealso:: https://i3wm.org/docs/ipc.html#_tree_reply

    :ivar border:
    :vartype border: str
    :ivar current_border_width:
    :vartype current_border_with: int
    :ivar floating:
    :vartype floating: bool
    :ivar focus: The focus stack for this container as a list of container ids.
        The "focused inactive" is at the top of the list which is the container
        that would be focused if this container recieves focus.
    :vartype focus: list(int)
    :ivar focused:
    :vartype focused: bool
    :ivar fullscreen_mode:
    :vartype fullscreen_mode: int
    :ivar ~.id:
    :vartype ~.id: int
    :ivar layout:
    :vartype layout: str
    :ivar marks:
    :vartype marks: list(str)
    :ivar name:
    :vartype name: str
    :ivar num:
    :vartype num: int
    :ivar orientation:
    :vartype orientation: str
    :ivar percent:
    :vartype percent: float
    :ivar scratchpad_state:
    :vartype scratchpad_state: str
    :ivar sticky:
    :vartype sticky: bool
    :ivar type:
    :vartype type: str
    :ivar urgent:
    :vartype urgent: bool
    :ivar window:
    :vartype window: int
    :ivar nodes:
    :vartype nodes: list(:class:`Con <i3ipc.Con>`)
    :ivar floating_nodes:
    :vartype floating_nodes: list(:class:`Con <i3ipc.Con>`)
    :ivar window_class:
    :vartype window_class: str
    :ivar window_instance:
    :vartype window_instance: str
    :ivar window_role:
    :vartype window_role: str
    :ivar window_title:
    :vartype window_title: str
    :ivar rect:
    :vartype rect: :class:`Rect <i3ipc.Rect>`
    :ivar window_rect:
    :vartype window_rect: :class:`Rect <i3ipc.Rect>`
    :ivar deco_rect:
    :vartype deco_rect: :class:`Rect <i3ipc.Rect>`
    :ivar geometry:
    :vartype geometry: :class:`Rect <i3ipc.Rect>`
    :ivar app_id: (sway only)
    :vartype app_id: str
    :ivar pid: (sway only)
    :vartype pid: int
    :ivar gaps: (gaps only)
    :vartype gaps: :class:`Gaps <i3ipc.Gaps>`
    :ivar representation: (sway only)
    :vartype representation: str
    :ivar visible: (sway only)
    :vartype visible: bool

    :ivar ipc_data: The raw data from the i3 ipc.
    :vartype ipc_data: dict
    """

    name: str
    nodes: List[Con]
    type: str
    window_class: str

    def __init__(self, data, parent, conn) -> None: ...
    def __iter__(self):  # -> Generator[Unknown, None, None]:
        """Iterate through the descendents of this node (breadth-first tree traversal)"""
        ...
    def root(self) -> Con:
        """Gets the root container.

        :returns: The root container.
        :rtype: :class:`Con`
        """
        ...
    def descendants(self) -> List[Con]:
        """Gets a list of all child containers for the container in
        breadth-first order.

        :returns: A list of descendants.
        :rtype: list(:class:`Con`)
        """
        ...
    def descendents(self) -> List[Con]:
        """Gets a list of all child containers for the container in
        breadth-first order.

        .. deprecated:: 2.0.1
           Use :func:`descendants` instead.

        :returns: A list of descendants.
        :rtype: list(:class:`Con`)
        """
        ...
    def leaves(self) -> List[Con]:
        """Gets a list of leaf child containers for this container in
        breadth-first order. Leaf containers normally contain application
        windows.

        :returns: A list of leaf descendants.
        :rtype: list(:class:`Con`)
        """
        ...
    def command(self, command: str) -> List[replies.CommandReply]:
        """Runs a command on this container.

        .. seealso:: https://i3wm.org/docs/userguide.html#list_of_commands

        :returns: A list of replies for each command in the given command
            string.
        :rtype: list(:class:`CommandReply <i3ipc.CommandReply>`)
        """
        ...
    def command_children(self, command: str) -> List[replies.CommandReply]:
        """Runs a command on the immediate children of the currently selected
        container.

        .. seealso:: https://i3wm.org/docs/userguide.html#list_of_commands

        :returns: A list of replies for each command that was executed.
        :rtype: list(:class:`CommandReply <i3ipc.CommandReply>`)
        """
        ...
    def workspaces(self) -> List[Con]:
        """Gets a list of workspace containers for this tree.

        :returns: A list of workspace containers.
        :rtype: list(:class:`Con`)
        """
        ...
    def find_focused(self) -> Optional[Con]:
        """Finds the focused container under this container if it exists.

        :returns: The focused container if it exists.
        :rtype: :class:`Con` or :class:`None` if the focused container is not
            under this container
        """
        ...
    def find_by_id(self, id: int) -> Optional[Con]:
        """Finds a container with the given container id under this node.

        :returns: The container with this container id if it exists.
        :rtype: :class:`Con` or :class:`None` if there is no container with
            this container id.
        """
        ...
    def find_by_pid(self, pid: int) -> List[Con]:
        """Finds all the containers under this node with this pid.

        :returns: A list of containers with this pid.
        :rtype: list(:class:`Con`)
        """
        ...
    def find_by_window(self, window: int) -> Optional[Con]:
        """Finds a container with the given window id under this node.

        :returns: The container with this window id if it exists.
        :rtype: :class:`Con` or :class:`None` if there is no container with
            this window id.
        """
        ...
    def find_by_role(self, pattern: str) -> List[Con]:
        """Finds all the containers under this node with a window role that
        matches the given regex pattern.

        :returns: A list of containers that have a window role that matches the
            pattern.
        :rtype: list(:class:`Con`)
        """
        ...
    def find_named(self, pattern: str) -> List[Con]:
        """Finds all the containers under this node with a name that
        matches the given regex pattern.

        :returns: A list of containers that have a name that matches the
            pattern.
        :rtype: list(:class:`Con`)
        """
        ...
    def find_titled(self, pattern: str) -> List[Con]:
        """Finds all the containers under this node with a window title that
        matches the given regex pattern.

        :returns: A list of containers that have a window title that matches
            the pattern.
        :rtype: list(:class:`Con`)
        """
        ...
    def find_classed(self, pattern: str) -> List[Con]:
        """Finds all the containers under this node with a window class that
        matches the given regex pattern.

        :returns: A list of containers that have a window class that matches the
            pattern.
        :rtype: list(:class:`Con`)
        """
        ...
    def find_instanced(self, pattern: str) -> List[Con]:
        """Finds all the containers under this node with a window instance that
        matches the given regex pattern.

        :returns: A list of containers that have a window instance that matches the
            pattern.
        :rtype: list(:class:`Con`)
        """
        ...
    def find_marked(self, pattern: str = ...) -> List[Con]:
        """Finds all the containers under this node with a mark that
        matches the given regex pattern.

        :returns: A list of containers that have a mark that matches the
            pattern.
        :rtype: list(:class:`Con`)
        """
        ...
    def find_fullscreen(self) -> List[Con]:
        """Finds all the containers under this node that are in fullscreen
        mode.

        :returns: A list of fullscreen containers.
        :rtype: list(:class:`Con`)
        """
        ...
    def workspace(self) -> Optional[Con]:
        """Finds the workspace container for this node if this container is at
        or below the workspace level.

        :returns: The workspace container if it exists.
        :rtype: :class:`Con` or :class:`None` if this container is above the
            workspace level.
        """
        ...
    def scratchpad(self) -> Con:
        """Finds the scratchpad container.

        :returns: The scratchpad container.
        :rtype: class:`Con`
        """
        ...
