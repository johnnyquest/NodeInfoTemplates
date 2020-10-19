<%namespace name="ni" module="nodegraphinfo"/>
<%inherit file="base.mako"/>

<%def name="particleSystems(branch)">
    % if branch is not None:
        <%
        # There's onlye one row, with only one value for POP info.
        info = branch.rows()[0][1]
        processed_info = info.replace('$separator', '<hr/>')
        %>

        <pre>
            ${processed_info}
        </pre>
    % endif
</%def>

<%
    popinfo = info.branches()['POP Info']
%>

${self.particleSystems(popinfo)}
