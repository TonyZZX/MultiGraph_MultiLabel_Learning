package cn.edu.neu.esm

import io.github.tonyzzx.gspan.Misc
import io.github.tonyzzx.gspan.model.*

import java.io.BufferedReader
import java.io.FileReader
import java.io.FileWriter
import java.io.IOException
import java.util.*
import kotlin.collections.Map.Entry

/**
 * Entropy-Based Sub-graph Mining
 */
class ESM {

    /*
     * Original variables of gSpan
     *
     * By Tony Zhu
     */

    private val trans: ArrayList<Graph> = ArrayList()
    private val dfsCode: DFSCode = DFSCode()
    private val dfsCodeIsMin: DFSCode = DFSCode()
    private val graphIsMin: Graph = Graph()

    private var id = 0L
    private var minSup = 0L
    private var minNodeNum = 0L
    private var maxNodeNum = 0L
    private var directed: Boolean = false
    private var writer: FileWriter? = null

    // Singular vertex handling stuff [graph][vertexLabel] = count.
    private val singleVertex: NavigableMap<Int, NavigableMap<Int, Int>>
    private val singleVertexLabel: NavigableMap<Int, Int>

    private val isMin: Boolean
        get() {
            if (dfsCode.size == 1)
                return true

            dfsCode.toGraph(graphIsMin)
            dfsCodeIsMin.clear()

            val root = TreeMap<Int, NavigableMap<Int, NavigableMap<Int, Projected>>>()
            val edges = ArrayList<Edge>()

            for (from in graphIsMin.indices)
                if (Misc.getForwardRoot(graphIsMin, graphIsMin[from], edges))
                    for (it in edges) {
                        val key1 = graphIsMin[from].label
                        val root1 = (root as MutableMap<Int, NavigableMap<Int, NavigableMap<Int, Projected>>>).computeIfAbsent(key1) { TreeMap() }
                        val key2 = it.eLabel
                        val root2 = (root1 as MutableMap<Int, NavigableMap<Int, Projected>>).computeIfAbsent(key2) { TreeMap() }
                        val key3 = graphIsMin[it.to].label
                        var root3: Projected? = root2[key3]
                        if (root3 == null) {
                            root3 = Projected()
                            root2[key3] = root3
                        }
                        root3.push(0, it, null)
                    }

            val fromLabel = root.firstEntry()
            val eLabel = fromLabel.value.firstEntry()
            val toLabel = eLabel.value.firstEntry()

            dfsCodeIsMin.push(0, 1, fromLabel.key, eLabel.key, toLabel.key)

            return isMinProject(toLabel.value)
        }

    /*
     * Added variables
     *
     * By Tony Zhu
     */

    // If allow to print out the result
    private var allowPrint: Boolean = false
    // Multi-Label Matrix
    private var labelMatrix = ArrayList<MultiLabel>()
    // Maximum number of sub-graphs that will be returned
    private var maxGraphNum = 0L
    // Maximum value of entropy that will be returned
    private var maxEntropy = 1.0
    // Number of labels
    private var labelNum = 0L
    // Extension: Record in which graphs frequent sub-graphs appear
    // map<sub-graph #, List<graph # it appears>>
    private val appearedGraphMap: NavigableMap<Int, ArrayList<Int>>
    // The result of frequent sub-graphs mining
    private val subGraphMap: NavigableMap<Int, Graph>

    /*
     * Added functions
     *
     * By Tony Zhu
     */

    @Throws(IOException::class)
    fun run(gSpanReader: FileReader, esmReader: FileReader, writer: FileWriter, minSup: Long, maxNodeNum: Long, minNodeNum: Long, maxGraphNum: Long, maxEntropy: Double) {
        runGSpan(gSpanReader, writer, minSup, maxNodeNum, minNodeNum)

        id = 0
        this.maxGraphNum = maxGraphNum
        this.maxEntropy = maxEntropy

        readESM(esmReader)
        runInternESM()
    }

    @Throws(IOException::class)
    private fun readESM(reader: FileReader) {
        var read = BufferedReader(reader)
        while (true) {
            val l = MultiLabel()
            read = l.read(read)
            if (l.multiLabels.isEmpty())
                break
            labelMatrix.add(l)

            if (labelNum == 0L) {
                labelNum = l.multiLabels.size.toLong()
            }
        }
        read.close()
    }

    @Throws(IOException::class)
    private fun runInternESM() {
        val subGraphEntropy = TreeMap<Int, Double>()
        for ((key, value) in appearedGraphMap) {
            var entropy = 0.0
            for (i in 0 until labelNum) {
                // count for pos and neg label
                var countPos = 0
                var countNeg = 0
                for (graphId in value) {
                    if (labelMatrix[graphId].multiLabels[i.toInt()] > 0) {
                        countPos++
                    } else {
                        countNeg++
                    }
                }
                // possibilities for pos and neg label
                val pPos = countPos * 1.0 / (countPos + countNeg)
                val pNeg = countNeg * 1.0 / (countPos + countNeg)
                // calculate the entropy
                entropy += -pPos * log2(pPos) - pNeg * log2(pNeg)
            }
            entropy /= (labelNum * 1.0)
            subGraphEntropy[key] = entropy
        }

        val sortedEntropy = entriesSortedByValues(subGraphEntropy)
        for (entry in sortedEntropy) {
            reportESM(entry)
        }
    }

    @Throws(IOException::class)
    private fun reportESM(entry: Entry<Int, Double>) {
        if (id >= maxGraphNum)
            return

        val g = subGraphMap[entry.key]
        val entropy = entry.value
        if (entropy > maxEntropy)
            return
        writer!!.write("t # " + id + " * " + entry.value + System.getProperty("line.separator"))
        g?.write(writer)
        ++id
    }

    /**
     * Run gSpan.
     *
     * @param reader     FileReader
     * @param writers    FileWriter
     * @param minSup     Minimum support
     * @param maxNodeNum Maximum number of nodes
     * @param minNodeNum Minimum number of nodes
     * @throws IOException
     */
    @Throws(IOException::class)
    private fun runGSpan(reader: FileReader, writers: FileWriter, minSup: Long, maxNodeNum: Long, minNodeNum: Long) {
        this.allowPrint = false
        run(reader, writers, minSup, maxNodeNum, minNodeNum)
    }

    @Throws(IOException::class)
    private fun reportGSpan(sup: Int, appearedGraphList: ArrayList<Int>) {
        // Filter to small/too large graphs.
        if (maxNodeNum > minNodeNum && dfsCode.countNode() > maxNodeNum)
            return
        if (minNodeNum > 0 && dfsCode.countNode() < minNodeNum)
            return

        val g = Graph(directed)
        dfsCode.toGraph(g)

        /*
         * Extension: Record in which graphs frequent sub-graphs appear
         *
         * By Tony Zhu
         */
        appearedGraphMap[id.toInt()] = appearedGraphList
        subGraphMap[id.toInt()] = g

        if (allowPrint) {
            writer!!.write("t # " + id + " * " + sup + System.getProperty("line.separator"))
            g.write(writer)
        }

        ++id
    }

    /**
     * Return the list of appeared graphs
     *
     * @param projected
     * @return List of appeared graphs
     */
    private fun getAppearedGraphList(projected: Projected): ArrayList<Int> {
        var oid = -0x1
        val appearedGraphList = ArrayList<Int>()

        for (cur in projected) {
            if (oid != cur.id) {
                appearedGraphList.add(cur.id)
            }
            oid = cur.id
        }

        return appearedGraphList
    }

    private fun getValue(i: Int?) = io.github.tonyzzx.gspan.Common.getValue(i)

    private fun log2(value: Double) = if (value == 0.0) 0.0 else Math.log(value) / Math.log(2.0)

    private fun <K, V : Comparable<V>> entriesSortedByValues(map: Map<K, V>): SortedSet<Entry<K, V>> {
        val sortedEntries = TreeSet<Entry<K, V>> { e1, e2 ->
            val res = e1.value.compareTo(e2.value)
            if (res != 0) res else 1
        }
        sortedEntries.addAll(map.entries)
        return sortedEntries
    }

    /*
     * Modified functions based on gSpan
     *
     * By Tony Zhu
     */

    init {
        singleVertex = TreeMap()
        singleVertexLabel = TreeMap()

        /*
         * Extension: Record in which graphs frequent sub-graphs appear
         *
         * By Tony Zhu
         */
        appearedGraphMap = TreeMap()
        subGraphMap = TreeMap()
    }

    /**
     * Special reportESM function for single node graphs.
     *
     * @param g
     * @param nCount
     * @throws IOException
     */
    @Throws(IOException::class)
    private fun reportSingle(g: Graph, nCount: NavigableMap<Int, Int>) {
        if (maxNodeNum > minNodeNum && g.size > maxNodeNum)
            return
        if (minNodeNum > 0 && g.size < minNodeNum)
            return

        /*
         * Extension: Record in which graphs frequent sub-graphs appear
         *
         * By Tony Zhu
         */
        var sup = 0
        val appearedGraphList = ArrayList<Int>()
        for ((key, value) in nCount) {
            val mSup = getValue(value)
            sup += mSup
            if (mSup > 0) {
                appearedGraphList.add(key)
            }
        }

        appearedGraphMap[id.toInt()] = appearedGraphList
        subGraphMap[id.toInt()] = g

        if (allowPrint) {
            writer!!.write("t # " + id + " * " + sup + System.getProperty("line.separator"))
            g.write(writer)
        }

        id++
    }

    /**
     * Recursive sub-graph mining function (similar to sub-procedure 1 Sub-graph_Mining in Yan2002).
     *
     * @param projected
     * @throws IOException
     */
    @Throws(IOException::class)
    private fun project(projected: Projected) {
        // Check if the pattern is frequent enough.
        val sup = support(projected)
        if (sup < minSup)
            return

        /*
         * The minimal DFS code check is more expensive than the support check,
         * hence it is done now, after checking the support.
         */
        if (!isMin) {
            return
        }

        /*
         * Extension: Record in which graphs frequent sub-graphs appear
         *
         * By Tony Zhu
         */
        val appearedGraphList = getAppearedGraphList(projected)
        // Output the frequent substructure
        reportGSpan(sup, appearedGraphList)

        /*
         * In case we have a valid upper bound and our graph already exceeds it,
         * return. Note: we do not check for equality as the DFS exploration may
         * still add edges within an existing sub-graph, without increasing the
         * number of nodes.
         */
        if (maxNodeNum > minNodeNum && dfsCode.countNode() > maxNodeNum)
            return

        /*
         * We just outputted a frequent sub-graph. As it is frequent enough, so
         * might be its (n+1)-extension-graphs, hence we enumerate them all.
         */
        val rmPath = dfsCode.buildRMPath()
        val minLabel = dfsCode[0].fromLabel
        val maxToc = dfsCode[rmPath[0]].to

        val newFwdRoot = TreeMap<Int, NavigableMap<Int, NavigableMap<Int, Projected>>>()
        val newBckRoot = TreeMap<Int, NavigableMap<Int, Projected>>()
        val edges = ArrayList<Edge>()

        // Enumerate all possible one edge extensions of the current substructure.
        for (aProjected in projected) {

            val id = aProjected.id
            val history = History(trans[id], aProjected)

            // XXX: do we have to change something here for directed edges?

            // backward
            for (i in rmPath.size - 1 downTo 1) {
                val e = Misc.getBackward(trans[id], history[rmPath[i]], history[rmPath[0]],
                        history)
                if (e != null) {
                    val key1 = dfsCode[rmPath[i]].from
                    val root1 = (newBckRoot as MutableMap<Int, NavigableMap<Int, Projected>>).computeIfAbsent(key1) { TreeMap() }
                    val key2 = e.eLabel
                    var root2: Projected? = root1[key2]
                    if (root2 == null) {
                        root2 = Projected()
                        root1[key2] = root2
                    }
                    root2.push(id, e, aProjected)
                }
            }

            // pure forward
            // FIXME:
            // here we pass a too large e.to (== history[rmPath[0]].to into getForwardPure, such that the assertion fails.
            //
            // The problem is:
            // history[rmPath[0]].to > trans[id].size()
            if (Misc.getForwardPure(trans[id], history[rmPath[0]], minLabel, history, edges))
                for (it in edges) {
                    val root1 = (newFwdRoot as MutableMap<Int, NavigableMap<Int, NavigableMap<Int, Projected>>>).computeIfAbsent(maxToc) { TreeMap() }
                    val key2 = it.eLabel
                    val root2 = (root1 as MutableMap<Int, NavigableMap<Int, Projected>>).computeIfAbsent(key2) { TreeMap() }
                    val key3 = trans[id][it.to].label
                    var root3: Projected? = root2[key3]
                    if (root3 == null) {
                        root3 = Projected()
                        root2[key3] = root3
                    }
                    root3.push(id, it, aProjected)
                }
            // backtracked forward
            for (aRmPath in rmPath)
                if (Misc.getForwardRmPath(trans[id], history[aRmPath!!], minLabel, history, edges))
                    for (it in edges) {
                        val key1 = dfsCode[aRmPath].from
                        val root1 = (newFwdRoot as MutableMap<Int, NavigableMap<Int, NavigableMap<Int, Projected>>>).computeIfAbsent(key1) { TreeMap() }
                        val key2 = it.eLabel
                        val root2 = (root1 as MutableMap<Int, NavigableMap<Int, Projected>>).computeIfAbsent(key2) { TreeMap() }
                        val key3 = trans[id][it.to].label
                        var root3: Projected? = root2[key3]
                        if (root3 == null) {
                            root3 = Projected()
                            root2[key3] = root3
                        }
                        root3.push(id, it, aProjected)
                    }
        }

        // Test all extended substructures.
        // backward
        for ((key, value) in newBckRoot) {
            for ((key1, value1) in value) {
                dfsCode.push(maxToc, key, -1, key1, -1)
                project(value1)
                dfsCode.pop()
            }
        }

        // forward
        for ((key, value) in newFwdRoot.descendingMap()) {
            for ((key1, value1) in value) {
                for ((key2, value2) in value1) {
                    dfsCode.push(key, maxToc + 1, -1, key1, key2)
                    project(value2)
                    dfsCode.pop()
                }
            }
        }
    }

    /*
     * Original functions of gSpan
     *
     * By Tony Zhu
     */

    /**
     * Run gSpan.
     *
     * @param reader     FileReader
     * @param writer    FileWriter
     * @param minSup     Minimum support
     * @param maxNodeNum Maximum number of nodes
     * @param minNodeNum Minimum number of nodes
     * @throws IOException
     */
    @Throws(IOException::class)
    private fun run(reader: FileReader, writer: FileWriter, minSup: Long, maxNodeNum: Long, minNodeNum: Long) {
        this.writer = writer
        id = 0
        this.minSup = minSup
        this.minNodeNum = minNodeNum
        this.maxNodeNum = maxNodeNum
        directed = false

        read(reader)
        runIntern()
    }

    @Throws(IOException::class)
    private fun read(reader: FileReader) {
        var read: BufferedReader? = BufferedReader(reader)
        while (true) {
            val g = Graph(directed)
            read = g.read(read)
            if (g.isEmpty())
                break
            trans.add(g)
        }
        read!!.close()
    }

    @Throws(IOException::class)
    private fun runIntern() {
        // In case 1 node sub-graphs should also be mined for, do this as pre-processing step.
        if (minNodeNum <= 1) {
            /*
             * Do single node handling, as the normal gSpan DFS code based
             * processing cannot find sub-graphs of size |sub-g|==1. Hence, we
             * find frequent node labels explicitly.
             */
            for (id in trans.indices) {
                for (nid in 0 until trans[id].size) {
                    val key = trans[id][nid].label
                    (singleVertex as MutableMap<Int, NavigableMap<Int, Int>>).computeIfAbsent(id) { TreeMap() }
                    if (singleVertex[id]?.get(key) == null) {
                        // number of graphs it appears in
                        singleVertexLabel[key] = getValue(singleVertexLabel[key]) + 1
                    }

                    singleVertex[id]?.set(key, getValue(singleVertex[id]?.get(key)) + 1)
                }
            }
        }
        /*
         * All minimum support node labels are frequent 'sub-graphs'.
         * singleVertexLabel[nodeLabel] gives the number of graphs it appears in.
         */
        for ((frequent_label, value) in singleVertexLabel) {
            if (value < minSup)
                continue

            // Found a frequent node label, reportESM it.
            val g = Graph(directed)
            val v = Vertex()
            v.label = frequent_label
            g.add(v)

            // [graph_id] = count for current substructure
            val counts = Vector<Int>()
            counts.setSize(trans.size)
            for ((key, value1) in singleVertex) {
                counts[key] = value1[frequent_label]
            }

            val gyCounts = TreeMap<Int, Int>()
            for (n in counts.indices) {
                if (counts[n] != null) {
                    gyCounts[n] = counts[n]
                }
            }

            reportSingle(g, gyCounts)
        }

        val edges = ArrayList<Edge>()
        val root = TreeMap<Int, NavigableMap<Int, NavigableMap<Int, Projected>>>()

        for (id in trans.indices) {
            val g = trans[id]
            for (from in g.indices) {
                if (Misc.getForwardRoot(g, g[from], edges)) {
                    for (it in edges) {
                        val key1 = g[from].label
                        val root1 = (root as MutableMap<Int, NavigableMap<Int, NavigableMap<Int, Projected>>>).computeIfAbsent(key1) { TreeMap() }
                        val key2 = it.eLabel
                        val root2 = (root1 as MutableMap<Int, NavigableMap<Int, Projected>>).computeIfAbsent(key2) { TreeMap() }
                        val key3 = g[it.to].label
                        var root3: Projected? = root2[key3]
                        if (root3 == null) {
                            root3 = Projected()
                            root2[key3] = root3
                        }
                        root3.push(id, it, null)
                    }
                }
            }
        }

        for ((key, value) in root) {
            for ((key1, value1) in value) {
                for ((key2, value2) in value1) {
                    // Build the initial two-node graph. It will be grown recursively within project.
                    dfsCode.push(0, 1, key, key1, key2)
                    project(value2)
                    dfsCode.pop()
                }
            }
        }
    }

    @Throws(IOException::class)
    private fun report(sup: Int) {
        // Filter to small/too large graphs.
        if (maxNodeNum > minNodeNum && dfsCode.countNode() > maxNodeNum)
            return
        if (minNodeNum > 0 && dfsCode.countNode() < minNodeNum)
            return

        val g = Graph(directed)
        dfsCode.toGraph(g)
        writer!!.write("t # " + id + " * " + sup + System.getProperty("line.separator"))
        g.write(writer)
        ++id
    }

    private fun support(projected: Projected): Int {
        var oid = -0x1
        var size = 0

        for (cur in projected) {
            if (oid != cur.id) {
                ++size
            }
            oid = cur.id
        }

        return size
    }

    private fun isMinProject(projected: Projected): Boolean {
        val rmPath = dfsCodeIsMin.buildRMPath()
        val minLabel = dfsCodeIsMin[0].fromLabel
        val maxToc = dfsCodeIsMin[rmPath[0]].to

        run {
            val root = TreeMap<Int, Projected>()
            var flg = false
            var newTo = 0

            var i = rmPath.size - 1
            while (!flg && i >= 1) {
                for (cur in projected) {
                    val history = History(graphIsMin, cur)
                    val e = Misc.getBackward(graphIsMin, history[rmPath[i]], history[rmPath[0]],
                            history)
                    if (e != null) {
                        val key1 = e.eLabel
                        var root1: Projected? = root[key1]
                        if (root1 == null) {
                            root1 = Projected()
                            root[key1] = root1
                        }
                        root1.push(0, e, cur)
                        newTo = dfsCodeIsMin[rmPath[i]].from
                        flg = true
                    }
                }
                --i
            }

            if (flg) {
                val eLabel = root.firstEntry()
                dfsCodeIsMin.push(maxToc, newTo, -1, eLabel.key, -1)
                return if (dfsCode[dfsCodeIsMin.size - 1]
                                .notEqual(dfsCodeIsMin[dfsCodeIsMin.size - 1])) false else isMinProject(eLabel.value)
            }
        }

        run {
            var flg = false
            var newFrom = 0
            val root = TreeMap<Int, NavigableMap<Int, Projected>>()
            val edges = ArrayList<Edge>()

            for (cur in projected) {
                val history = History(graphIsMin, cur)
                if (Misc.getForwardPure(graphIsMin, history[rmPath[0]], minLabel, history, edges)) {
                    flg = true
                    newFrom = maxToc
                    for (it in edges) {
                        val key1 = it.eLabel
                        val root1 = (root as MutableMap<Int, NavigableMap<Int, Projected>>).computeIfAbsent(key1) { TreeMap() }
                        val key2 = graphIsMin[it.to].label
                        var root2: Projected? = root1[key2]
                        if (root2 == null) {
                            root2 = Projected()
                            root1[key2] = root2
                        }
                        root2.push(0, it, cur)
                    }
                }
            }

            var i = 0
            while (!flg && i < rmPath.size) {
                for (cur in projected) {
                    val history = History(graphIsMin, cur)
                    if (Misc.getForwardRmPath(graphIsMin, history[rmPath[i]], minLabel, history, edges)) {
                        flg = true
                        newFrom = dfsCodeIsMin[rmPath[i]].from
                        for (it in edges) {
                            val key1 = it.eLabel
                            val root1 = (root as MutableMap<Int, NavigableMap<Int, Projected>>).computeIfAbsent(key1) { TreeMap() }
                            val key2 = graphIsMin[it.to].label
                            var root2: Projected? = root1[key2]
                            if (root2 == null) {
                                root2 = Projected()
                                root1[key2] = root2
                            }
                            root2.push(0, it, cur)
                        }
                    }
                }
                ++i
            }

            if (flg) {
                val eLabel = root.firstEntry()
                val toLabel = eLabel.value.firstEntry()
                dfsCodeIsMin.push(newFrom, maxToc + 1, -1, eLabel.key, toLabel.key)
                return if (dfsCode[dfsCodeIsMin.size - 1]
                                .notEqual(dfsCodeIsMin[dfsCodeIsMin.size - 1])) false else isMinProject(toLabel.value)
            }
        }

        return true
    }
}
