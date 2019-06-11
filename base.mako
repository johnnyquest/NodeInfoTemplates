<%namespace name="ni" module="nodegraphinfo"/>

<style>
<%include file="base.css"/>
</style>

<%def name="kv_table(items, **kwargs)">
    <table>
        ${ kv_rows(items, **kwargs) }
    </table>
</%def>

<%def name="kv_row(key, value, cls=u'', tt=False, renames=None, keywidth=u'80')">
    <tr>
        <td width="${ keywidth }" class="${cls} key">
            ${ renames.get(key, key) if renames else key }
        </td>
        <td class="${cls} value">
            % if tt or key == "Comment":
                <pre>${ value.replace(u'\n', u'<br/>') }</pre>
            % else:
                ${ value }
            % endif
        </td>
    </tr>
</%def>

<%def name="vector_row(key, value, cls=u'', renames=None, keywidth=u'80')">
    <% components = ni.format_components(value) %>
    <tr>
        <td width="${ keywidth }" class="${cls} key">
            ${ renames.get(key, key) if renames else key }
        </td>
        % for i, num in enumerate(components):
            <td class="${cls} value" align="right">
                <tt>${num}${u"," if i < len(components) - 1 else u""}</tt>
            </td>
        % endfor
    </tr>
</%def>

<%def name="kv_rows(rows, hidden=(), **kwargs)">
    % for row in rows:
        % if row[0] and row[0] not in hidden:
            ${ kv_row(row[0], row[1], **kwargs) }
        % endif
    % endfor
</%def>

<%def name="branch_rows(branch, recursive=False, **kwargs)">
    ${ kv_rows(branch.rows(), **kwargs) }
    % if recursive:
        % for subbranch in branch.branches().values():
            ${branch_rows(subbranch, recursive=recursive, **kwargs)}
        % endfor
    % endif
</%def>

<%def name="properties(branch, recursive=False, **kwargs)">
    % if branch:
        <table width="100%">
            ${branch_rows(branch, recursive=recursive, **kwargs)}
        </table>
    % endif
</%def>

<%def name="show_general()">
    <% general = info.branches().get('General Info', None) %>
    ${properties(general, recursive=True)}
</%def>

<%def name="branch_table(branch)">
    <%
        heads = branch.headings()
    %>
    <table width="100%">
        <tr>
            % for head in heads:
                <th>${ head }</th>
            % endfor
        </tr>
        % for row in branch.rows():
            <tr>
                % for value in row:
                    <td>${ value }</td>
                % endfor
            </tr>
        % endfor
    </table>
</%def>

${ next.body() }
