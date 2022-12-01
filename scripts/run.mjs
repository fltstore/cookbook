import fs from 'fs'
import path from 'path'

const ignoreList = [
  ".git",
  ".github",
]

const kDebugMode = false

const kMessage = 'Auto Code Generated. DO NOT EDIT.'

const cwd = process.cwd()
const workSpace = path.join(cwd, "assets", "HowToCook")

const pubspecYamlFilePath  = path.join(cwd, 'pubspec.yaml')

const tabsize = 4

function createTabsize(length) {
  return Array.from({length}).map(_=> ' ').join('')
}

const kTabSpace = createTabsize(tabsize)

/**
 * @type {Set<string>}
 */
const reusltMap = new Set()

function createPubspecAssets() {
  const dir = fs.readdirSync(workSpace)
  dir.filter(item=> {
    return !ignoreList.includes(item)
  }).map(item=> {
    const _path = path.join(workSpace, item)
    return _path
  }).map(item=> {
    loopPath(item)
  })
  let cacheIndex = -1
  const result = []
  for (const rwmux of reusltMap) {
    const rwmuxList = rwmux.split('/')
    if (cacheIndex <= -1) {
      for (let index = 0; index < rwmuxList.length; index++) {
        const element = rwmuxList[index];
        if (element == 'assets') {
          cacheIndex = index
          break
        }
      }
    }
    if (cacheIndex <= -1) {
      console.log('render asset flag is error')
      process.exit(0)
    }
    const popResult = rwmuxList.slice(cacheIndex)
    let reslove = popResult.join('/')
    reslove = `${reslove}/`
    result.push(reslove)
  }
  let respone = result.join( `\n${kTabSpace}- `)
  respone = `${kTabSpace}- ${respone}`
  return respone
}

/**
 * @param {string} rawPath 
 */
function loopPath(rawPath) {
  const mustLoop = fs.lstatSync(rawPath).isDirectory()
  if (mustLoop) {
    reusltMap.add(rawPath)
    const dirs = fs.readdirSync(rawPath)
    dirs.map(item=> {
      const cachePath = path.join(rawPath, item)
      loopPath(cachePath)
    })
  }
}

/**
 * 
 * @param {string} rewriteData 
 */
function reWritePubspecYaml(rewriteData) {
  const data = fs.readFileSync(pubspecYamlFilePath).toString('utf-8')
  const lines = data.split("\n")
  for (let index = 0; index < lines.length; index++) {
    const line = lines[index].trim();
    if (line == '# assets:') {
      lines.splice(index, 1)
      lines.splice(index, 0, `${createTabsize(2)}assets: # ${kMessage}`)
      lines.splice(index + 1, 0, `${createTabsize(4)}- assets/HowToCook/README.md`)
      lines.splice(index + 2, 0, rewriteData)
      lines.splice(index + 3, 0, `${ kTabSpace }####### END ######`)
      break
    }
  }
  const output = lines.join("\n")
  const filename = kDebugMode ? 'dev.yaml' : 'pubspec.yaml'
  const outputFilePath = path.join(cwd, filename)
  fs.writeFileSync(outputFilePath, output, 'utf-8')
}

function setup() {
  const pubspecAssets = createPubspecAssets()
  reWritePubspecYaml(pubspecAssets)
}

function main() {
  setup()
}

function clean() {
  const pubspecContent = fs.readFileSync(pubspecYamlFilePath).toString('utf-8')
  const lines = pubspecContent.split('\n')
  const firstInitFlag = '# assets'
  const myGenFlag = 'assets: #'
  const endGenFlag = '####### END'
  let startIndex = -1, endIndex = -1
  for (let index = 0; index < lines.length; index++) {
    const line = lines[index];
    const $line = line.trim()
    if ($line.startsWith(firstInitFlag)) {
      console.log("未生成过, 不需要初始化 :)")
      process.exit(0)
    } else if ($line.startsWith(myGenFlag)) {
      startIndex = index
    } else if ($line.startsWith(endGenFlag)) {
      endIndex  = index
      break
    }
  }
  if (startIndex <= -1 || endIndex <= -1) {
    console.log("没有找到标识符, 无法删除生成的资源文件集")
    process.exit(0)
  }
  lines.splice(startIndex, endIndex - startIndex + 1)
  const pushPrefix = `${createTabsize(2)}${firstInitFlag}:`
  lines.splice(startIndex,0, pushPrefix)
  const result = lines.join('\n')
  const outputFile = kDebugMode ? path.join(cwd, 'dd.yaml') : pubspecYamlFilePath
  fs.writeFileSync(outputFile, result, 'utf-8')
}

// NOTE:
// => 每次Git提交之前需要提前 clean 一次
// => 首次clone下来之后执行一下生成操作
;(async ()=> {
  const args = process.argv
  let action = 'gen'
  if (args.length >= 3) {
    const targetAction = args[2]
    targetAction == 'clean' ? (action = 'clean') : null
  }
  if (action == 'clean') {
    clean()
  } else {
    main()
  }
})()