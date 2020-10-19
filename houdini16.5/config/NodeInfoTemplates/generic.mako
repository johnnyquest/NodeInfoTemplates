<%namespace name="ni" module="nodegraphinfo"/>
<%inherit file="base.mako"/>

<%
    known_branches = ('General Info', 'Dependency', 'Errors',
                      'OBJ Info', 'SOP Info', 'DOP Info', 'POP Info',
                      'COP Info', 'CHOP Info', 'ROP Info', 'L-System SOP Info',
                      'Scripted SHOP Info', 'Shader SHOP Info')
    renames = {
        "Last Cook Time": "Last Cook",
        "Created Time": "Created",
        "Modified Time": "Modified",
        "Contained Nodes": "Contains",
        "Synchronized with Definition": "Synchronized",
        "Options Set Last Timestep": "Opts Last TS",
    }

    branches = info.branches()

    # Treat "subnet output" info separately
    outputs = []
    if "Subnetwork SOP Info" in branches:
        subinfo = branches.pop("Subnetwork SOP Info")
        for label, path in subinfo.rows():
            m = ni.search("Output [0-9]+", label)
            if m:
                outputs.append((m.group(0), path))

    unknown = [branches[key] for key in branches
               if not any(key.startswith(kb) for kb in known_branches)]

    mems = [("SOP Info", "Memory"), ("CHOP Info", "Memory Usage")]
    memory = None
    for branchname, memkey in mems:
        if branchname in branches:
            membranch = branches[branchname]
            for key, value in membranch.rows():
                if key == memkey:
                    memory = value
                    break


%>

<%
    # imre: getting node author name
    author = '...'
    try:
        author = hou.hscript('opstat -u %s' % infoitem.path())[0]
        author = author.split(' ')[-1].split('\n')[0]
    except:
        author = "?"
%>

% for branch in unknown:
    ${ self.properties(branch, recursive=True, renames=renames) }
% endfor

<table>
    % for label, path in outputs:
        <tr>
            <td class="key">${ label }</td>
            <td class="value"><a href="node:../${path}">${path}</a></td>
        </tr>
    % endfor

    % if memory is not None:
        ${ self.kv_row("Memory", memory )}
    % endif

    % if "General Info" in branches:
        ${ self.branch_rows(branches["General Info"], recursive=True, renames=renames)}
    % endif
    
    <tr>
        <td class="key">Author</td>
        <td class="value">${author}</td>
    </tr>
    
</table>