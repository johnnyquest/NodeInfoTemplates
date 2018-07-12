<%namespace name="ni" module="nodegraphinfo"/>
<%inherit file="geometry.mako"/>

<%
    chopinfo = info.branches().get('CHOP Info')
    if chopinfo:
        d = dict(chopinfo.rows())
        branches = chopinfo.branches()
        qbranch = branches.get('Quaternions')
        tbranch = branches.get('Track Attributes')
        tsbranch = branches.get('Track Sample Attributes')
        cbranch = branches.get('Clip Attributes')
        csbranch = branches.get('Clip Sample Attributes')
        chanbranch = branches.get('Channel Info')

        idict = dict(chopinfo.rows())

    attrs = [
        ('Clip Sample Attributes', 'points'),
        ('Track Attributes', 'primitives'),
        ('Track Sample Attributes', 'vertices'),
        ('Clip Attributes', 'detail')
    ]

    renames = {
        "Left Extend": "&#8672;",
        "Right Extend": "&#8674;",
        "Sample Rate (Hz)": "Samples/sec",
        "Track Attributes": "Channel attrs",
        "Clip Attributes": "Clip attrs",
        "Track Sample Attributes": "Sample attrs",
        "Clip Sample Attributes": "Sample/Clip attrs"
    }

    # Instead of a linear list, we want to display the "properties" as two
    # columns, so we will explicitly list the items in each column here:
    props = [
        ( # Left column
            "Channels",
            "Start/End Samples", "Start/End Frames", "Start/End Seconds",
            "Min/Max Values",
        ),
        ( # Right column
            "Sample Rate (Hz)",
            "Length Samples", "Length Frames", "Length Seconds",
            # Memory is displayed in the "generic.mako" template, not here
            None,
        )
    ]

%>

%if chopinfo:
    <table width="100%">
        % for keys in zip(*props):
            <tr>
                % for k in keys:
                    % if k and k in idict:
                        <td width="100" class="key">${ renames.get(k, k) }</td>
                        <td class="value">${ idict[k]}</td>
                    % endif
                % endfor
            </tr>
        % endfor
    </table>

    ## Quaternions
    % if qbranch:
        <%
            qrows = qbranch.rows()
            showname = "quaternions"
            if verbose or showname in showall:
                limit = len(qrows)
            else:
                limit = min(10, len(qrows))
        %>
        <hr />
        <table>
            <tr>
                <th colspan="${ len(qbranch.headings()) }">Quaternions</th>
            </tr>
            % for row in qrows[:limit]:
                <tr>
                    % for value in row:
                        <td>${value}</td>
                    % endfor
                </tr>
            % endfor
            % if limit < len(qrows):
                <tr>
                    <td colspan="${ len(qbranch.headings()) }">
                        <a href="more:${showname}">${len(qrows) - limit} more...</a>
                    </td>
                </tr>
            % endif
        </table>
    % endif

    %if tbranch or cbranch or tsbranch or csbranch:
        <hr/>
        <table>
            % for name, style in attrs:
                % if name in branches:
                    ${ self.show_attrs(branches, name, style, renames, verbose, debug) }
                % endif
            % endfor
        </table>
    % endif

    ## Channels
    %if chanbranch:
        <%
            heads = chanbranch.headings()
            rows = chanbranch.rows()
            showname = "channels"
            if verbose or showname in showall:
                limit = len(rows)
            else:
                limit = min(20, len(rows))
        %>
        <hr/>
        <table>
            <tr>
                % for head in heads:
                    <th>${renames.get(head, head)}</th>
                % endfor
            </tr>
            % for row in rows[:limit]:
                <%
                    d = dict(zip(heads, row))
                %>
                <tr>
                    <td class="channel">${ d["Channel Name"] }</td>
                    <td>${ d["Left Extend"] }</td>
                    <td>${ d["Right Extend"] }</td>
                    <td><tt>${ ni.format_number(d["Min"]) }</tt></td>
                    <td><tt>${ ni.format_number(d["Max"]) }</tt></td>
                    <td><tt>${ ni.format_number(d["Current"]) }</tt></td>
                    <% override = d["Override"].strip()  %>
                    <td>
                        <%
                            node = None
                            if override and "/" in override:
                                nodename = override.rsplit("/", 1)[0]
                                node = infoitem.node(nodename)
                        %>
                        % if node:
                            <a href="node:${node.path()}">${override}</a>
                        % elif override:
                            ${override}
                        % else:
                            None
                        % endif
                    </td>
                </tr>
            % endfor
            % if limit < len(rows):
                <tr>
                    <td colspan="${len(heads)}">
                        <a href="more:${showname}">${len(rows) - limit} more...</a>
                    </td>
                </tr>
            % endif
        </table>
    % endif
%endif
