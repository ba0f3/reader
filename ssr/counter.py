import requests
import json
from ssr import logger

headers = {'content-type': 'application/json'}


def count_all(url):
    logger.debug("Fetching like count for: %s" % url)
    total = 0
    count = count_google_plus(url)
    logger.debug("Google Plus: %s" % count)
    total += count

    count = count_facebook(url)
    logger.debug("Facebook: %s" % count)
    total += count

    count = count_twitter(url)
    total += count
    logger.debug("Twitter: %s" % count)

    count = count_stumbleupon(url)
    total += count
    logger.debug("Stumbleupon: %s" % count)

    count = count_linkedin(url)
    total += count
    logger.debug("Linkedin: %s" % count)

    return total


def count_twitter(url):
    try:
        r = requests.get("https://cdn.api.twitter.com/1/urls/count.json?url=%s" % url, headers=headers)
        if r.status_code == requests.codes.ok:
            result = json.loads(r.text.encode("utf-8"))
            return int(result['count'])
    except Exception as ex:
        logger.error(ex.message)
        return 0


def count_facebook(url):
    try:
        r = requests.get("https://graph.facebook.com/?id=%s" % url, headers=headers)
        if r.status_code == requests.codes.ok:
            result = json.loads(r.text.encode("utf-8"))
            return int(result['shares']) if 'shares' in result else 0
    except Exception as ex:
        logger.error(ex.message)
        return 0


def count_stumbleupon(url):
    try:
        r = requests.get("https://www.stumbleupon.com/services/1.01/badge.getinfo?url=%s" % url, headers=headers)
        if r.status_code == requests.codes.ok:
            result = json.loads(r.text.encode("utf-8"))
            return int(result['result']['views']) if result['result']['in_index'] else 0
    except Exception as ex:
        logger.error(ex.message)
        return 0


def count_linkedin(url):
    try:
        r = requests.get("https://www.linkedin.com/countserv/count/share?url=%s&format=json" % url, headers=headers)
        if r.status_code == requests.codes.ok:
            result = json.loads(r.text.encode("utf-8"))
            return int(result['count'])
    except Exception as ex:
        logger.error(ex.message)
        return 0


def count_google_plus(url):
    "fetch +1 count from google plus"

    """
    this method is for batch request
    payload = list()

    for url in args:
        payload.append({
            "method": "pos.plusones.get",
            "id": "p",
            "params": {
                "nolog": True,
                "id": url
            },
            "jsonrpc": "2.0",
            "key": "p",
            "apiVersion": "v1"
        })
    """
    payload = {
       "method": "pos.plusones.get",
       "id": "p",
       "params": {
           "nolog": True,
           "id": url
       },
       "jsonrpc": "2.0",
       "key": "p",
       "apiVersion": "v1"
    }
    try:
        r = requests.post("https://clients6.google.com/rpc?key=AIzaSyCKSbrvQasunBoV16zDH9R33D88CeLr9gQ", data=json.dumps(payload), headers=headers)
        if r.status_code == requests.codes.ok:
            result = json.loads(r.text.encode("utf-8"))
            return int(result['result']['metadata']['globalCounts']['count'])
    except Exception as ex:
        logger.error(ex.message)
        return 0
