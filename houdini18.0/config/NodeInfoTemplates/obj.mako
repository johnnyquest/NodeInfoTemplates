<%namespace name="ni" module="nodegraphinfo"/>
<%inherit file="base.mako"/>

<%def name="obj_row(d, key, label=None, is_node=0, tt=False)">
    <%
	value = d.get(key)
	if isinstance(value, basestring):
	    value = value.replace('\n', '<br/>\n')
    %>
    % if value:
        <tr>
            <td width="100" class="key">${ label or key }</td>
            <td class="value">
                % if is_node == 1:
                    <a href="node:${ infoitem.path() }/${ value }">${ value }</a>
                % elif is_node == 2:
                    <a href="node:${ value }">${ value }</a>
                % elif tt:
                    <tt>${ value }</tt>
                % else:
                    ${ value }
                % endif
            </td>
        </tr>
    % endif
</%def>

<%
    objinfo = info.branches().get('OBJ Info')
    d = dict(objinfo.rows()) if objinfo else {}
%>

<table width="100%">
    ## Time Dependent Display appears in "dependency.mako" template
    ${ obj_row(d, "    Display  SOP", "Display", 1) }
    ${ obj_row(d, "     Render  SOP", "Render", 1) }
    ${ obj_row(d, "Constraints CHOP", "Constraints", 2) }
    ${ obj_row(d, "Transform Order", "Transform Order", tt=True) }
    ${ obj_row(d, "Local Transform", "Local Transform", tt=True) }
    ${ obj_row(d, "World Transform", "World Transform", tt=True) }
    ${ obj_row(d, "Pre-Transform", "Pre-Transform", tt=True) }
</table>
