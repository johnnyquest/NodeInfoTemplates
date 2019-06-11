<%namespace name="ni" module="nodegraphinfo"/>
<%inherit file="geometry.mako"/>

<%
    from collections import defaultdict
    
    chopinfo = info.branches().get('CHOP Info')
    if chopinfo:
        d = dict(chopinfo.rows())
        branches = chopinfo.branches()
        qbranch = branches.get('Quaternions')
        dbranch = branches.get('Capture Regions')
        tbranch = branches.get('Track Attributes')
        tsbranch = branches.get('Track Sample Attributes')
        cbranch = branches.get('Clip Attributes')
        csbranch = branches.get('Clip Sample Attributes')
        chanbranch = branches.get('Channel Info')

        idict = dict(chopinfo.rows())

        # Take branches dictionary and create a dictionary with lists of 
        # branch NodeInfoTrees as values, needed for show_attrs method in 
        # geometry.mako
        allbranches = defaultdict(list)
        for name, value in branches.items():
            allbranches[name].append(value)

        self.mainbranches = branches

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
        "Clip Sample Attributes": "Sample/Clip attrs",

	"Start/End Samples":"Samples", 
	"Start/End Frames":"Frames",
	"Start/End Seconds":"Seconds",

        "Length Samples":"Samples",
	"Length Frames":"Frames",
	"Length Seconds":"Seconds"
    }

    # Instead of a linear list, we want to display the "properties" as two
    # columns, so we will explicitly list the items in each column here:
    props = [
        ( # Left column
            "Channels",
	    "Mode"
        ),
        ( # Right column
            "Sample Rate (Hz)",
	    "Min/Max Values"
        )
    ]

    # Instead of a linear list, we want to display the "properties" as two
    # columns, so we will explicitly list the items in each column here:
    props2 = [
        ( # Left column
            "Start/End Samples", "Start/End Frames", "Start/End Seconds",
        ),
        ( # Right column
            "Length Samples", "Length Frames", "Length Seconds",
        )
    ]

    # Instead of a linear list, we want to display the "properties" as two
    # columns, so we will explicitly list the items in each column here:
    props3 = [
        ( # Left column
            "Quaternions Ordering",
        ),
        ( # Right column
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
    <table width="100%">
	<tr>
		<th width="100" class="rightheader">Start/End</th>
		<th></th>
		<th width="100" class="rightheader">Length</th>
		<th></th>
	</tr>
        % for keys in zip(*props2):
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
        <hr/>
        <table>
            % for row in qrows[:limit]:
                <tr>
                    % for value in row:
                        <td class="value">${value}</td>
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

    ## Capture Regions
    % if dbranch:
        <%
            drows = dbranch.rows()
            showname = "capture_regions"
            if verbose or showname in showall:
                limit = len(drows)
            else:
                limit = min(10, len(drows))
        %>
        <hr/>
        <table>
            % for row in drows[:limit]:
                <tr>
                    % for value in row:
                        <td class="value">${value}</td>
                    % endfor
                </tr>
            % endfor
            % if limit < len(drows):
                <tr>
                    <td colspan="${ len(dbranch.headings()) }">
                        <a href="more:${showname}">${len(drows) - limit} more...</a>
                    </td>
                </tr>
            % endif
        </table>
    % endif

    %if tbranch or cbranch or tsbranch or csbranch:
        <hr/>
        <table>
            % for name, style in attrs:
                % if name in allbranches:
                    ${ self.show_attrs(allbranches, name, style, renames, verbose, debug) }
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
                    <td><tt>${ ni.format_number(d["Current"]) }</tt></td>
                    <td>${ d["Left Extend"] }</td>
                    <td>${ d["Right Extend"] }</td>
                    <td><tt>${ ni.format_number(d["Min"]) }</tt></td>
                    <td><tt>${ ni.format_number(d["Max"]) }</tt></td>
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
