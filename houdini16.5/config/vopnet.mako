<%namespace name="ni" module="nodegraphinfo"/>
<%inherit file="base.mako"/>

<%
    nodetype = None
    try:
        nodetype = infoitem.definedType()
    except hou.OperationFailed:
        pass

    instances = None
    if nodetype:
        instances = list(nodetype.instances())
        showname = "vop_instances"
        if verbose or showname in showall:
            limit = len(instances)
        else:
            limit = min(16, len(instances))
%>

% if nodetype:
    <table>
        <tr>
        <td>
            Defines
        </td>
        <td>
            ${nodetype.category().name()}
        </td>
        <td>
            Operator Name
        </td>
        <td>
            ${nodetype.description()}
        </td>
        <td>
            Internal Name
        </td>
        <td>
            ${nodetype.name()}
        </td>
        </tr>
    </table>
% endif

% if instances:
    <ul>
        % for node in instances[:limit]:
            <li>
            <a href="node:${node.path()}">${node.path()}</a>
            </li>
        % endfor
        % if limit < len(instances):
            <li>
                <a href="more:${showname}">${len(instances) - limit} more...</a>
            </li>
        % endif
    </ul>
% endif
