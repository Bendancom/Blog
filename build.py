#!/usr/bin/env python3
import os
import re
import subprocess
import json

from urllib import parse
from datetime import datetime
from string import Template
from pathlib import Path
from tomllib import load
from collections import defaultdict
from bs4 import BeautifulSoup

# Test
from pprint import pprint

# Configuration
BASE_DIR = Path(__file__).parent
HTML_DIR = BASE_DIR / "html"
COMPONENTS_DIR = HTML_DIR / "components"
CONTAINER_DIR = HTML_DIR / "container"
CONTENT_DIR = BASE_DIR / "content"
ASSETS_DIR = BASE_DIR / "assets"
OUTPUT_DIR = BASE_DIR / "public"
CACHE_DIR = BASE_DIR / "cache"

componentStyles = {}
for file in (ASSETS_DIR / "style" / "components").iterdir():
    componentStyles[file.stem] = {}
    if file.is_dir():
        componentStyles[file.stem]["css"] = f"<link rel=\"stylesheet\" type=\"text/css\" href=\"/{(file.relative_to(BASE_DIR) / file.with_suffix(".css").name)}\">"
        componentStyles[file.stem]["subcss"] = {}
        for subbfile in file.rglob("*.css"):
            componentStyles[file.stem]["subcss"][subbfile.stem] = f"<link rel=\"stylesheet\" type=\"text/css\" href=\"/{ subbfile.relative_to(BASE_DIR) }\">"
    else:
        componentStyles[file.stem]["css"] = f"<link rel=\"stylesheet\" type=\"text/css\" href=\"/{file.relative_to(BASE_DIR).with_suffix(".css")}\">"

containerStyles = {}
for file in (ASSETS_DIR / "style" / "container").iterdir():
    containerStyles[file.stem] = f"<link rel=\"stylesheet\" type=\"text/css\" href=\"/{file.relative_to(BASE_DIR)}\">"

defaultStyles = []
for file in (ASSETS_DIR / "style").glob("*.css"):
    defaultStyles.append(f"<link rel=\"stylesheet\" type=\"text/css\" href=\"/{file.relative_to(BASE_DIR)}\">")

javascripts = {}
for file in (ASSETS_DIR / "js").rglob("*.js"):
    match file.stem:
        case "find":
            javascripts[file.stem] = f"<script type=\"module\" src=\"/{file.relative_to(BASE_DIR)}\"></script>"
        case _:
            javascripts[file.stem] = f"<script src=\"/{file.relative_to(BASE_DIR)}\"></script>"

with open(BASE_DIR / "config.toml","rb") as f:
    config = load(f)
with open(BASE_DIR / "lang.toml","rb") as f:
    language = load(f)

templates = {}
for file in (HTML_DIR / "template").rglob("*"):
    templates[file.stem] = Template(file.read_text())

postContainer = Template((CONTAINER_DIR / "post.html").read_text())
homeContainer = Template((CONTAINER_DIR / "home.html").read_text())
archiveContainer = Template((CONTAINER_DIR / "archive.html").read_text())
aboutContainer = Template((CONTAINER_DIR / "about.html").read_text())

components = {}
for file in COMPONENTS_DIR.iterdir():
    components[file.stem] = {}
    if file.is_dir():
        if (file / file.with_suffix(".html").name).exists():
            components[file.stem]["template"] = Template((file / file.with_suffix(".html").name).read_text(encoding="UTF-8"))
        components[file.stem]["subcomponents"] = {}
        for sub in file.rglob("*.html"):
            if sub.name == file.stem + ".html":
                continue
            components[file.stem]["subcomponents"][sub.stem] = Template(sub.read_text(encoding="UTF-8"))
    else:
        components[file.stem]["template"] = Template(file.read_text(encoding="UTF-8"))

def getMetadata(file: Path) -> dict:
    print(f"Parsing {file.relative_to(BASE_DIR)}")

    command = [
        "typst",
        "query",
        "--features",
        "html",
        "--root",
        str(BASE_DIR),
        str(file),
        "metadata"
    ]
    result = subprocess.run(command,capture_output=True,text=True)
    if result.returncode != 0:
        print(f"Failed Parsing {file.relative_to(BASE_DIR)}")
        print(result.stderr)
        return


    jsondatas = json.loads(result.stdout)
    metadatas = []
    for i in jsondatas:
        if "metadata" in i["value"]:
            metadatas.append(i["value"]["metadata"])
    
    def recursive(data):
        if isinstance(data,dict):
            func = data.pop("func",None)
            text = data.pop("text",None)
            body = data.pop("body",None)
            if func:
                if func == "sequence":
                    return recursive(data["children"])
                if func == "equation":
                    func = "math." + func
                if func == "space":
                    return " "
            if text:
                if len(data) > 0:
                    return f"#{func}(\"{text}\" {"," + ",".join(data)})"
                else:
                    return f"#{func}(\"{text}\")"
            if body:
                return f"#{func}([{ "".join(recursive(body))}]{"," + ",".join(data)})"
            return f"${func}({",".join(data)})"
        if isinstance(data,list):
            tmp = []
            for i in data:
                tmp.append(recursive(i))
            return tmp
        return data

    metadata = {}
    for i in metadatas:
        for key,value in i.items():
            if key == "date" or key== "lastModDate":
                if value != None:
                    metadata[key] = datetime.strptime(value,"%Y-%m-%d")
                else:
                    metadata[key] = value
            else:
                metadata[key] = recursive(value)

    if len(metadata) == 0:
        return

    pattern = r'"([^"]*)"'
    metadata["title"] = "".join(metadata["title"])
    metadata["titleString"] = "".join(re.findall(pattern,metadata["title"]))
    metadata["premalink"] = Path(f"{metadata["lang"][0:2]}/posts")
    if metadata["order"] is not None:
        metadata["premalink"] = metadata["premalink"] / "series"
    else:
        metadata["premalink"] = metadata["premalink"] / "single"

    metadata["premalink"] = metadata["premalink"] / metadata["titleString"]

    if isinstance(metadata["authors"],str):
        metadata["authors"] = [metadata["authors"]]
    if metadata["tags"] is not None:
        if isinstance(metadata["tags"],str):
            metadata["tags"] = [metadata["tags"]]

    if metadata["subtitle"] is not None:
        metadata["subtitle"] = "".join(metadata["subtitle"])
        metadata["subtitleString"] = "".join(re.findall(pattern,metadata["subtitle"]))
        metadata["premalink"] = metadata["premalink"] / metadata["subtitleString"]
    else:
        metadata["subtitleString"] = None

    if metadata["description"] is not None:
        metadata["description"] = "".join(metadata["description"])
        metadata["descriptionString"] = "".join(re.findall(pattern,metadata["description"]))
    else:
        metadata["descriptionString"] = None

    metadata["relativePath"] = str(file.relative_to(CONTENT_DIR))
    return metadata

def sortMetadata(metadatas: list) -> list:
    from collections import defaultdict,OrderedDict

    result = []
    for item in metadatas:
        if item["order"] is not None:
            find = list(filter(lambda o: o.get("title") == item["titleString"],result))
            if len(find) == 0:
                result.append({
                    "title": item["titleString"],
                    "latest": item,
                    "metadatas": [item]
                })
            else:
                finder = find[0]
                for i in finder["metadatas"]:
                    if item["order"] == i["order"]:
                        print(f"Order repeated with {item["title"]} in {i["relativePath"]} and {item["relativePath"]}")
                        return
                    if i["subtitleString"] == item["subtitleString"]:
                        print(f"Order repeated with {item["title"]} in {i["relativePath"]} and {item["relativePath"]}")
                        return
                    if item["date"] > finder["latest"]["date"]:
                        finder["latest"] = item
                finder["metadatas"].append(item)
                finder["metadatas"].sort(key=lambda j: j["order"])
        else:
            result.append({
                "title": item["titleString"],
                "latest": item
            })
        result.sort(key=lambda d: d["latest"]["date"],reverse=True)
    return result

def compileTypst(file: Path) -> str:
    print(f"Compiling {file.relative_to(BASE_DIR)}")
    
    command = [
        "typst",
        "compile",
        "--features",
        "html",
        "--format",
        "html",
        "--root",
        str(BASE_DIR),
        str(file),
        "-"
    ]
    
    result = subprocess.run(command,capture_output=True,text=True)
    if result.returncode != 0:
        print(f"Failed Parsing {file.relative_to(BASE_DIR)}")
        print(result.stderr)
        return

    html = result.stdout

    bodyIndex = html.find("<body>") + 6
    bodyRIndex = html.rfind("</body>") - 1
    htmlContent = html[bodyIndex:bodyRIndex]

    replace = re.sub("(<div role=\"math\">[\\s]+<svg class=\"typst-frame\" style=\"[\\w: ;]+)(width:[\\w .]+;)","\\1",htmlContent)

    return replace

def generateSEO(metadata: dict) -> str:
    lang = metadata.get("lang")[0:2]
    title = metadata.get("titleString")
    description = metadata.get("descriptionString")
    authors = metadata.get("authors")

    subtitle = metadata.get("subtitleString",None)
    tags = metadata.get("tags",None)
    category = metadata.get("category",None)
    date = metadata.get("date",None)
    lastmoddate = metadata.get("lastmoddate",None)
    image = metadata.get("image",None)
    
    full_title = f"{title}｜{subtitle}" if subtitle else title
    
    url = f"{config["info"]["url"]}/{lang}/{title}/{subtitle}" if subtitle else f"{config["info"]["url"]}/{lang}/{title}"   

    seo_tags = [
        f'<title>{full_title}</title>',
        f'<meta name="description" content="{description}">',
        f'<meta name="author" content="{authors}">',
        f'<meta property="og:title" content="{full_title}">',
        f'<meta property="og:description" content="{description}">',
        f'<meta property="og:url" content="{url}">',
        f'<meta property="article:author" content="{authors}">',
    ]
    
    if tags or category:
        seo_tags.append(f'<meta property="og:type" content="article">')
    else:
        seo_tags.append(f'<meta property="og:type" content="website">')

    if lastmoddate or date:
        seo_tags.append(f'<meta name="date" content="{lastmoddate.strftime("%Y-%m-%d") if lastmoddate else date.isoformat()}">')
    if tags:
        seo_tags.append(f'<meta name="keywords" content="{tags}">')
    if category:
        seo_tags.append(f'<meta name="category" content="{category}">')
    if date:
        f'<meta property="article:published_time" content="{date.strftime("%Y-%m-%d")}">'
    if image:
        seo_tags.append(f'<meta property="og:image" content="{image}">')

    return "\n".join(seo_tags)

def generateHead(metadata: dict, js: list, styles: list,haveSEO:bool) -> str:
    return components["head"]["template"].substitute({
        "js": "\n".join(js),
        "SEO": generateSEO(metadata) if haveSEO else "",
        "style": "\n".join(styles),
        "url": config["info"]["url"],
        "icon": config["info"]["icon"],
        "lang": metadata["lang"][0:2],
        "siteTitle": language["config"][metadata["lang"][0:2]]["siteTitle"],
        "feed": language["config"][metadata["lang"][0:2]]["feed"]
    })

def generateNavbar(metadata: dict,selector: bool,finder: bool,languageSwitch: bool,languageList: list) -> dict:
    navbar = {}
    for key,value in components["navbar"]["subcomponents"].items():
        match key:
            case "language-switch":
                languageShortName = []
                languageName = []
                for lang in languageList:
                    if lang == config["info"]["defaultLanguage"]:
                        languageName.append(f"<button class=\"{lang} current\" onclick=\"languageSwitch('{lang}')\">{language["config"][lang]["languageName"]}</button>")
                        languageShortName.append(f"<div class=\"{lang} current\">{language["config"][lang]["languageShortName"]}</div>")
                    else:
                        languageName.append(f"<button class=\"{lang}\" onclick=\"languageSwitch('{lang}')\">{language["config"][lang]["languageName"]}</button>")
                        languageShortName.append(f"<div class=\"{lang}\">{language["config"][lang]["languageShortName"]}</div>")
                navbar[key] = value.substitute({
                    "languageShortName": "\n".join(languageShortName),
                    "languageName": "\n".join(languageName),
                    "system": language["config"][metadata["lang"][0:2]]["system"]
                })
            case _:
                navbar[key] = value.substitute({
                    **language["config"][metadata["lang"][0:2]],
                    "lang": metadata["lang"][0:2]
                })
    navbarActions = []

    if finder:
        navbarActions.append(navbar["find"])

    navbarActions.append(navbar["display-setting"])
    if selector:
        navbarActions.append(navbar["selector-switch"])
    if languageSwitch and len(languageList) > 1:
        navbarActions.append(navbar["language-switch"])
    navbarActions.append(navbar["scheme-switch"])
    navbarActions.append(navbar["mobile-menu"])

    return components["navbar"]["template"].substitute({
        "actions": "\n".join(navbarActions),
        "lang": metadata["lang"][0:2],
        **language["config"][metadata["lang"][0:2]]
    })

def generateSideBar(metadata: dict,alltags: list,allcategories: dict) -> str:
    htmlCategories = []
    for key,value in allcategories.items():
        htmlCategories.append(f'<a href="/{metadata["lang"][0:2]}/archive/?category={parse.quote(key)}" class="category-item"><span class="category-name">{key}</span><span class="category-count">{value}</span></a>')

    htmlTags = []
    for tag in alltags:
        htmlTags.append(f'<a href="/{metadata["lang"][0:2]}/archive/?tag={parse.quote(tag)}" class="tag">{tag}</a>')

    sidebar = {}
    for key,value in components["sidebar"]["subcomponents"].items():
        sidebar[key] = value.substitute({
            **language["config"][metadata["lang"][0:2]],
            "lang": metadata["lang"][0:2],
            **config["info"],
            "allcategories": "\n".join(htmlCategories),
            "alltags": "\n".join(htmlTags),
        })

    sidebarWidget = [sidebar["profile"],sidebar["categories"],sidebar["tags"]]

    return components["sidebar"]["template"].substitute({
        "widgets": "\n".join(sidebarWidget)
    })

def generateMetadata(metadata: dict,TitleLink: bool) -> str:
    meta = {}
    data = metadata.copy()
    date = data.pop("date").strftime("%Y-%m-%d")
    lastModDate = data.pop("lastModDate",None)

    title = data["titleString"]
    if data["subtitleString"]:
        title = f"{title}｜{data["subtitleString"]}"
    
    category = data.pop("category",None)
    if category:
        category = f"<a href=\"/{metadata["lang"][0:2]}/archive/?category={parse.quote(category)}\">{category}</a>"

    tags = data.pop("tags",None)
    if tags:
        tags = [f"<a href=\"/{metadata["lang"][0:2]}/archive/?tag={parse.quote(tag)}\">{tag}</a>" for tag in tags]
        tags = "<span class=\"tag-divider\">|</span>".join(tags)


    if lastModDate:
        lastModDate = lastModDate.strftime("%Y-%m-%d")

    premalink = f"/{data.pop("premalink")}"

    for key,value in components["metadata"]["subcomponents"].items():
        if lastModDate and key == "lastModDate":
            meta[key] = value.substitute({
                **data,
                "date": date,
                "lastModDate": lastModDate,
                "tags": tags if tags else "",
                "category": category if category else "",
                "title": title,
                "description": data["descriptionString"],
                "premalink": premalink
            })
        else:
            meta[key] = value.substitute({
                **metadata,
                "date": date,
                "tags": tags if tags else "",
                "category": category if category else "",
                "title": title,
                "description": data["descriptionString"],
                "premalink": premalink
            })

    metas = []
    if TitleLink:
        metas.append(meta["titleLink"])
    else:
        metas.append(meta["title"])
    metas.append(meta["date"])
    if lastModDate:
        metas.append(meta["lastModDate"])
    if category:
        metas.append(meta["category"])
    if tags:
        metas.append(meta["tags"])
    metas.append(meta["description"])

    return components["metadata"]["template"].substitute({
        "metadataItems": "\n".join(metas)
    })

def generateFeed(lang: str,metadatas: list) -> str:
    sorted_metadatas = sorted(metadatas, key=lambda d: d["date"], reverse=True)
    latest_date = sorted_metadatas[0]["date"]
    
    entries = []
    for metadata in sorted_metadatas:
        entry = []
        entry.append("<entry>")
        entry.append(f"<title>{metadata["titleString"]}</title>")
        if metadata["subtitleString"]:
            entry.append(f"<subtitle>{metadata["subtitleString"]}</subtitle>")
        for author in metadata["authors"]:
            entry.append(f"<author><name>{author}</name></author>")
        entry.append(f"<link href=\"{config["info"]["url"]}/{metadata["premalink"]}\"/>")
        entry.append(f"<id>{config["info"]["url"]}/{metadata["premalink"]}</id>")
        entry.append(f"<published>{metadata["date"].strftime("%Y-%m-%d")}</published>")
        if metadata["lastModDate"]:
            entry.append(f"<updated>{metadata["lastModDate"].strftime("%Y-%m-%d")}</updated>")
        else:
            entry.append(f"<updated>{metadata["date"].strftime("%Y-%m-%d")}</updated>")
        if metadata["order"] is not None:
            entry.append(f"<category term=\"{language["config"][lang]["series"]}\" scheme=\"{config["info"]["url"]}/{lang}/posts/\"/>")
            entry.append(f"<category term=\"{metadata["titleString"]}\" scheme=\"{config["info"]["url"]}/{lang}/posts/series/\"/>")
        else:
            entry.append(f"<category term=\"{language["config"][lang]["single"]}\" scheme=\"{config["info"]["url"]}/{lang}/posts/\"/>")

        if metadata["descriptionString"]:
            entry.append(f"<summary>{metadata["descriptionString"]}</summary>")
    
        entry.append(f"<content type=\"html\"><![CDATA[{metadata["content"]}]]></content>")
        entry.append("</entry>")
        
        entries.append("\n".join(entry))
    
    feed = []
    feed.append(f"<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
    feed.append(f"<feed xmlns=\"http://www.w3.org/2005/Atom\" xml:lang=\"{lang}\">")
    feed.append(f"<title>{language["config"][lang]["siteTitle"]}</title>")
    feed.append(f"<subtitle>{language["config"][lang]["siteDescription"]}</subtitle>")
    feed.append(f"<link href=\"{config["info"]["url"]}/{lang}\"/>")
    feed.append(f"<link href=\"{config["info"]["url"]}/{lang}/feed.atom\" rel=\"self\"/>")
    feed.append(f"<id>{config["info"]["url"]}/{lang}/</id>")
    feed.append(f"<updated>{latest_date.strftime("%Y-%m-%d")}</updated>")
    feed.append(f"<icon>{config["info"]["url"]}/{config["info"]["icon"]}</icon>")
    feed.extend(entries)
    feed.append("</feed>")
    
    output_file = OUTPUT_DIR / lang / "feed.atom"
    output_file.parent.mkdir(exist_ok=True, parents=True)
    output_file.write_text("\n".join(feed), encoding="UTF-8")

    import feedparser

    test = feedparser.parse(output_file)

def generateTemplate(template: Template,component: dict,lang: str,container: str,outputFile: Path):
    outputFile.parent.mkdir(exist_ok=True,parents=True)
    outputFile.write_text(template.substitute({
        "container": container,
        **component,
        "lang": lang,
        "siteAuthor": language["config"][lang]["siteAuthor"] if lang != "" else "",
        "year": config["copyright"]["year"],
        "sign": config["copyright"]["sign"],
        "license": config["copyright"]["license"]
    }))

def generateHome(lang: str,metadatas: list,alltags: list,allcategories: dict,languageList: list):
    cards = []
    for data in sorted(metadatas,key=lambda d: d["date"],reverse=True):
        cards.append(components["postcard"]["template"].substitute({
            "metadata": generateMetadata(data,TitleLink=True),
            "link": components["postcard"]["subcomponents"]["symbollink"].substitute({
                "premalink": f"/{data["premalink"]}"
            }),
            "type": "series" if data["order"] is not None else "single"
        }))

    metadata = {
        "lang": lang,
        "titleString": language["config"][lang]["siteTitle"],
        "authors": [language["config"][lang]["siteAuthor"]],
        "descriptionString": language["config"][lang]["siteDescription"],
        "category": None,
        "tags": None,
        "image": f"{config["info"]["url"]}/assets/image/avatar.png"
    }

    home = homeContainer.substitute({
        "postCards": "\n".join(cards)
    })

    js = [
        javascripts["language-switch"],
        javascripts["display-setting"],
        javascripts["scheme-switch"],
        javascripts["selector-switch"]
    ]

    styles = [
        containerStyles["home"],
        componentStyles["sidebar"]["css"],
        componentStyles["postcard"]["css"],
        componentStyles["navbar"]["css"],
        componentStyles["navbar"]["subcss"]["display-setting"],
        componentStyles["navbar"]["subcss"]["language-switch"],
        componentStyles["navbar"]["subcss"]["scheme-switch"],
        componentStyles["navbar"]["subcss"]["selector-switch"],
        componentStyles["navbar"]["subcss"]["links"],
        componentStyles["navbar"]["subcss"]["logo"],
        componentStyles["navbar"]["subcss"]["mobile-menu"],
        componentStyles["metadata"]["css"],
        componentStyles["metadata"]["subcss"]["title"],
        componentStyles["metadata"]["subcss"]["description"],
        componentStyles["metadata"]["subcss"]["icon"],
        componentStyles["metadata"]["subcss"]["tags"],
    ]
    styles.extend(defaultStyles)

    component = {
        "head": generateHead(
            metadata,
            js,
            styles,
            haveSEO=True
        ),
        "navbar": generateNavbar(
            metadata,
            selector=True,
            finder=False,
            languageList=languageList,
            languageSwitch=True
        ),
        "sidebar": generateSideBar(metadata,alltags,allcategories)
    }

    generateTemplate(
        template=templates["within-sidebar"],
        container=home,
        lang=lang,
        component=component,
        outputFile= OUTPUT_DIR / lang / "index.html"
    )

def generatePosts(metadatas: list,alltags: list,allcategories: dict):
    js = [
        "<script src=\"https://cdn.jsdelivr.net/npm/segmentit@2.0.3/dist/umd/segmentit.min.js\"></script>",
        javascripts["find"],
        javascripts["display-setting"],
        javascripts["scheme-switch"],
    ]

    styles = [
        containerStyles["post"],
        componentStyles["article"]["css"],
        componentStyles["sidebar"]["css"],
        componentStyles["postcard"]["css"],
        componentStyles["navbar"]["css"],
        componentStyles["navbar"]["subcss"]["display-setting"],
        componentStyles["navbar"]["subcss"]["find"],
        componentStyles["navbar"]["subcss"]["scheme-switch"],
        componentStyles["navbar"]["subcss"]["links"],
        componentStyles["navbar"]["subcss"]["logo"],
        componentStyles["navbar"]["subcss"]["mobile-menu"],
        componentStyles["metadata"]["css"],
        componentStyles["metadata"]["subcss"]["title"],
        componentStyles["metadata"]["subcss"]["description"],
        componentStyles["metadata"]["subcss"]["icon"],
        componentStyles["metadata"]["subcss"]["tags"],
        componentStyles["pagination"]["css"],
        componentStyles["pagination"]["subcss"]["next"],
        componentStyles["pagination"]["subcss"]["previous"],
    ]
    styles.extend(defaultStyles)

    def Post(metadata,pagination):
        outputFile = OUTPUT_DIR / metadata["premalink"] / "index.html"

        lang = ""
        match (metadata["lang"][0:2]):
            case "zh":
                lang = "zh-CN"
            case "en":
                lang = "en"

        post = postContainer.substitute({
            "lang": lang,
            "content": metadata["content"],
            "metadata": generateMetadata(metadata,TitleLink=False),
            "title": metadata["titleString"],
            "subtitle": metadata["subtitleString"] if metadata["subtitleString"] else "",
            "fulltitle": "".join([metadata["titleString"],"｜",metadata["subtitleString"]]) if metadata["subtitleString"] else metadata["titleString"],
            "authors": " ".join(metadata["authors"]),
            "date": metadata["date"].strftime("%Y-%m-%d"),
            "category": metadata["category"] if "category" in metadata else "",
            "tags": " ".join(metadata["tags"]) if "tags" in metadata else "",
            "description": metadata["descriptionString"] if metadata["descriptionString"] else "",
            "pagination": pagination
        })

        component = {
            "head": generateHead(
                metadata,
                js,
                styles,
                haveSEO=True
            ),
            "navbar": generateNavbar(
                metadata,
                selector=False,
                finder=True,
                languageSwitch=False,
                languageList=[]
            ),
            "sidebar": generateSideBar(
                metadata,
                alltags,
                allcategories
            ),
        }

        generateTemplate(
            template=templates["within-sidebar"],
            container=post,
            lang=lang[0:2],
            component=component,
            outputFile=outputFile
        )

    for data in sortMetadata(metadatas):
        if "metadatas" in data:
            for i,metadata in enumerate(data["metadatas"]):
                previous = "<div id=\"pagination-previous\"></div>"
                if i != 0:
                    previous = components["pagination"]["subcomponents"]["previous"].substitute({
                        "previousSubtitle": data["metadatas"][i-1]["subtitleString"],
                        "previousOrder": data["metadatas"][i-1]["order"],
                        "divider": "｜",
                        "previousPremalink": f"/{data["metadatas"][i-1]["premalink"]}"
                    })
                _next = "<div id=\"pagination-next\"></div>"
                if i < len(data["metadatas"]) - 1:
                    _next = components["pagination"]["subcomponents"]["next"].substitute({
                        "nextSubtitle": data["metadatas"][i+1]["subtitleString"],
                        "nextOrder": data["metadatas"][i+1]["order"],
                        "divider": "｜",
                        "nextPremalink": f"/{data["metadatas"][i+1]["premalink"]}"
                    })
                pagination = components["pagination"]["template"].substitute({
                    "previous": previous,
                    "next": _next
                })

                Post(metadata,pagination)
        else:
            Post(data["latest"],"")

    

def generateArchive(lang: str,metadatas: list,alltags: list,allcategories: dict,languageList: list):
    js = [
        javascripts["display-setting"],
        javascripts["scheme-switch"],
        javascripts["language-switch"],
        javascripts["archive"],
        javascripts["selector-switch"],
    ]

    styles = [
        containerStyles["archive"],
        componentStyles["postcard"]["css"],
        componentStyles["single"]["css"],
        componentStyles["sidebar"]["css"],
        componentStyles["navbar"]["css"],
        componentStyles["navbar"]["subcss"]["display-setting"],
        componentStyles["navbar"]["subcss"]["scheme-switch"],
        componentStyles["navbar"]["subcss"]["language-switch"],
        componentStyles["navbar"]["subcss"]["selector-switch"],
        componentStyles["navbar"]["subcss"]["links"],
        componentStyles["navbar"]["subcss"]["logo"],
        componentStyles["navbar"]["subcss"]["mobile-menu"],
        componentStyles["metadata"]["css"],
        componentStyles["metadata"]["subcss"]["title"],
        componentStyles["metadata"]["subcss"]["description"],
        componentStyles["metadata"]["subcss"]["icon"],
        componentStyles["metadata"]["subcss"]["tags"],
        componentStyles["series"]["css"],
        componentStyles["series"]["subcss"]["latest-link"],
        componentStyles["series"]["subcss"]["latest-date"],
        componentStyles["series"]["subcss"]["series-link"],

    ]
    styles.extend(defaultStyles)

    archiveItems = []

    for data in sortMetadata(metadatas):
        if "metadatas" in data:
            seriesLinks = []
            latestDates = []
            latestLinks = []
            for one in data["metadatas"]:
                seriesLinks.append(components["series"]["subcomponents"]["series-link"]
                    .substitute({
                        "subtitle": one["subtitleString"] if one["subtitleString"] else "",
                        "date": one["date"].strftime("%Y-%m-%d"),
                        "divider": "｜",
                        "category": one["category"],
                        "tags": " ".join(one["tags"]),
                        "premalink": f"/{one["premalink"]}",
                        "order": one["order"],
                        "latest": "latest" if data["latest"]["date"] == one["date"] else ""
                    }))
                latestDates.append(components["series"]["subcomponents"]["latest-date"]
                    .substitute({
                        "date": one["date"].strftime("%Y-%m-%d"),
                        "category": one["category"],
                        "tags": " ".join(one["tags"]),
                    }))
                latestLinks.append(components["series"]["subcomponents"]["latest-link"]
                    .substitute({
                        "subtitle": one["subtitleString"] if one["subtitleString"] else "",
                        "divider": "｜",
                        "date": one["date"].strftime("%Y-%m-%d"),
                        "category": one["category"],
                        "tags": " ".join(one["tags"]),
                        "premalink": f"/{one["premalink"]}",
                        "order": one["order"]
                    }))


            archiveItems.append(components["series"]["template"].substitute({
                "title": data["latest"]["titleString"],
                "latestDates": "\n".join(latestDates),
                "seriesLinks": "\n".join(seriesLinks),
                "latestLinks": "\n".join(latestLinks)
            }))

        else:
            archiveItems.append(components["single"]["template"].substitute({
                "title": data["latest"]["titleString"],
                "subtitle": data["latest"]["subtitleString"] if data["latest"]["subtitleString"] else "",
                "divider": "｜" if data["latest"]["subtitleString"] else "",
                "date": data["latest"]["date"].strftime("%Y-%m-%d"),
                "category": data["latest"]["category"],
                "tags": " ".join(data["latest"]["tags"]),
                "premalink": f"/{data["latest"]["premalink"]}"
            }))

    archive = archiveContainer.substitute({
        "archiveItems": "\n".join(archiveItems),
    })

    metadata = {
        "lang": lang,
        "titleString": language["config"][lang]["siteTitle"],
        "authors": [language["config"][lang]["siteAuthor"]],
        "descriptionString": language["config"][lang]["siteDescription"],
        "category": None,
        "tags": None,
        "image": f"{config["info"]["url"]}/assets/image/avatar.png"
    }

    component = {
        "head": generateHead(
            metadata,
            js,
            styles,
            haveSEO=True
        ),
        "navbar": generateNavbar(
            metadata,
            selector=True,
            finder=False,
            languageList=languageList,
            languageSwitch=True
        ),
        "sidebar": generateSideBar(metadata,alltags,allcategories)
    }

    generateTemplate(
        template=templates["within-sidebar"],
        component=component,
        container=archive,
        lang=lang,
        outputFile= OUTPUT_DIR / lang / "archive" / "index.html"
    )

def generateAbout(metadata: dict,aboutContent: str,alltags: list,allcategories: dict,languageList: list):
    js = [
        javascripts["language-switch"],
        javascripts["display-setting"],
        javascripts["scheme-switch"],
    ]

    styles = [
        containerStyles["about"],
        componentStyles["sidebar"]["css"],
        componentStyles["article"]["css"],
        componentStyles["navbar"]["css"],
        componentStyles["navbar"]["subcss"]["display-setting"],
        componentStyles["navbar"]["subcss"]["language-switch"],
        componentStyles["navbar"]["subcss"]["scheme-switch"],
        componentStyles["navbar"]["subcss"]["links"],
        componentStyles["navbar"]["subcss"]["logo"],
        componentStyles["navbar"]["subcss"]["mobile-menu"],
    ]
    styles.extend(defaultStyles)

    about = aboutContainer.substitute({
        "about": aboutContent
    })

    component = {
        "head": generateHead(
            metadata,
            js,
            styles,
            haveSEO=True
        ),
        "navbar": generateNavbar(
            metadata,
            selector=False,
            finder=False,
            languageList=languageList,
            languageSwitch=True
        ),
        "sidebar": generateSideBar(metadata,alltags,allcategories)
    }

    generateTemplate(
        template=templates["within-sidebar"],
        component=component,
        container=about,
        lang=metadata["lang"][0:2],
        outputFile= OUTPUT_DIR / metadata["lang"][0:2] / "about" / "index.html"
    )

def build():
    from shutil import copytree,rmtree

    # Get metadata
    metadatas = defaultdict(list)
    alltags = defaultdict(set)
    allcategories = defaultdict(dict)
    languagelist = set()
    about = defaultdict(dict)
    for file in CONTENT_DIR.rglob("*.typ"):
        metadata = getMetadata(file)
        if metadata is None:
            continue
        lang = metadata["lang"][0:2]
        languagelist.add(lang)

        if file.relative_to(CONTENT_DIR).parts[0] == "about":
            about[lang]["content"] = compileTypst(file)
            about[lang]["metadata"] = metadata
            continue
        
        if metadata["tags"] is not None:
            alltags[lang].update(metadata["tags"])
        if metadata["category"] is not None:
            if metadata["category"] in allcategories[lang]:
                allcategories[lang][metadata["category"]] += 1
            else:
                allcategories[lang][metadata["category"]] = 1

        metadata["content"] = compileTypst(CONTENT_DIR / metadata["relativePath"])

        metadatas[lang].append(metadata)

    # Clear output
    if OUTPUT_DIR.exists():
        rmtree(OUTPUT_DIR)
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    # Copy
    copytree(ASSETS_DIR, OUTPUT_DIR / "assets")

    # Generate Index
    generateTemplate(
        template=templates["index"],
        component={
            "supportLanguage": json.dumps(list(languagelist),ensure_ascii=False),
            "defaultLanguage": config["info"]["defaultLanguage"],
            "icon": config["info"]["icon"]
        },
        lang="",
        container="",
        outputFile= OUTPUT_DIR / "index.html"
    )

    for lang in metadatas.keys():
        generateHome(
            lang,
            metadatas[lang],
            alltags[lang],
            allcategories[lang],
            languageList=languagelist
        )
        generateAbout(
            about[lang]["metadata"],
            about[lang]["content"],
            alltags[lang],
            allcategories[lang],
            languageList=languagelist
        )
        generateArchive(
            lang,
            metadatas[lang],
            alltags[lang],
            allcategories[lang],
            languageList=languagelist
        )
        generatePosts(
            metadatas[lang],
            alltags=alltags[lang],
            allcategories=allcategories[lang]
        )
        generateFeed(
            lang,
            metadatas[lang]
        )

    print(f"\n✅ Build complete! Output directory: {OUTPUT_DIR}")
    print(f"\nTo preview the site, run a local server:")
    print(f"  python -m http.server 8000 --directory {OUTPUT_DIR}")


if __name__ == "__main__":
    build()
