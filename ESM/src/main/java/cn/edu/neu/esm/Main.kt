package cn.edu.neu.esm

import org.apache.commons.cli.*
import java.io.File
import java.io.FileReader
import java.io.FileWriter
import kotlin.system.exitProcess

fun main(args: Array<String>) {
    val arguments = Arguments.getInstance(args)

    val inDataFile = File(arguments.inDataFilePath)
    val inLabelFile = File(arguments.inLabelFilePath)
    val outFile = File(arguments.outFilePath)
    FileReader(inDataFile).use({ inDataReader ->
        FileReader(inLabelFile).use({ inLabelReader ->
            FileWriter(outFile).use({ writer ->
                val esm = ESM()
                println("ESM is running...")
                esm.run(inDataReader, inLabelReader, writer, arguments.minSup, arguments.maxNodeNum, arguments.minNodeNum, arguments.maxGraphNum)
                println("It's done! The result is in ${arguments.outFilePath}")
            })
        })
    })
}

private class Arguments private constructor(private val args: Array<String>) {
    lateinit var inDataFilePath: String
    lateinit var inLabelFilePath: String
    var minSup = 0L
    var minNodeNum = 0L
    var maxNodeNum = Long.MAX_VALUE
    var maxGraphNum = Long.MAX_VALUE
    lateinit var outFilePath: String

    companion object {
        private var arguments: Arguments? = null

        fun getInstance(args: Array<String>): Arguments {
            arguments = Arguments(args)
            if (args.isNotEmpty()) {
                arguments!!.initFromCmd()
            } else {
                arguments!!.initFromRun()
            }
            return arguments as Arguments
        }
    }

    /***
     * User inputs args.
     */
    private fun initFromCmd() {
        val options = Options()
        options.addRequiredOption("d", "data", true, "(Required) File path of data set")
        options.addRequiredOption("l", "label", true, "(Required) File path of label")
        options.addRequiredOption("s", "sup", true, "(Required) Minimum support")
        options.addOption("i", "min-node", true, "Minimum number of nodes for each sub-graph")
        options.addOption("a", "max-node", true, "Maximum number of nodes for each sub-graph")
        options.addOption("g", "max-graph", true, "Maximum number of sub-graphs that will be returned")
        options.addOption("r", "result", true, "File path of result")
        options.addOption("h", "help", false, "Help")

        val parser = DefaultParser()
        val formatter = HelpFormatter()
        val cmd: CommandLine
        try {
            cmd = parser.parse(options, args)
            if (cmd.hasOption("h")) {
                formatter.printHelp("ESM", options)
                exitProcess(0)
            }
        } catch (e: ParseException) {
            formatter.printHelp("ESM", options)
            exitProcess(1)
        }

        inDataFilePath = cmd.getOptionValue("d")
        inLabelFilePath = cmd.getOptionValue("l")
        minSup = cmd.getOptionValue("s").toLong()
        minNodeNum = cmd.getOptionValue("i", "0").toLong()
        maxNodeNum = cmd.getOptionValue("a", Long.MAX_VALUE.toString()).toLong()
        maxGraphNum = cmd.getOptionValue("g", Long.MAX_VALUE.toString()).toLong()
        outFilePath = cmd.getOptionValue("r", inDataFilePath + "_result")
    }

    /***
     * User runs it directly.
     */
    private fun initFromRun() {
        println("Please input the file path of data set: ")
        inDataFilePath = readLine()!!
        println("Please input the file path of label: ")
        inLabelFilePath = readLine()!!
        println("Please set the minimum support: ")
        minSup = readLine()!!.toLong()
        outFilePath = inDataFilePath + "_result"
    }
}